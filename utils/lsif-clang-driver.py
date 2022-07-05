#!/usr/bin/env python3

import argparse
import os
import shutil
import json
import multiprocessing as mp
import pathlib
import tempfile
import subprocess
import sys
import time

def run_lsif_clang(q, sema, lsif_clang_abspath, compile_commands_abspath):
    err = None
    exitcode, output = 0, ''
    try:
        proc = subprocess.run([lsif_clang_abspath, compile_commands_abspath],
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        output = proc.stdout.decode('utf-8')
        # Looks like lsif-clang's exit code is always 0 :(
        if proc.returncode != 0 or 'error: ' in output:
            exitcode = 1
    except Exception as e:
        err = e
    finally:
        q.put((exitcode, output, compile_commands_abspath))
        sema.release()
        if err:
            raise err

def failure_message(output, lsif_clang_abspath, compile_commands_abspath, quiet):
    msg = ""
    if not quiet:
        msg = 'Found lsif-clang failure (stdout+stderr below):'
        msg += '\n--------------------------------------------------------------\n'
        msg += output
        if msg[-1] != '\n':
            msg += '\n'
        msg += '--------------------------------------------------------------\n'
        msg += '\n'
    msg += 'Reproduce the failure by running:\n  {} {}\n'.format(lsif_clang_abspath, compile_commands_abspath)
    return msg

# From https://stackoverflow.com/a/34736291/2682729
class NegateAction(argparse.Action):
    def __call__(self, parser, ns, values, option):
        setattr(ns, self.dest, option[2:4] != 'no')

def default_main():
    parser = argparse.ArgumentParser()
    parser.add_argument('lsif_clang_path', help='Path to lsif-clang')
    parser.add_argument('compile_commands_path', help='Path to compile_commands.json file, intended to be passed to lsif-clang')
    parser.add_argument('--fail-fast', '--no-fail-fast', action=NegateAction, help='Should we exit after finding the first failure? (default: true)', nargs=0)
    parser.add_argument('--concurrency', type=int, default=os.cpu_count(), help='Number of lsif-clang processes to spawn at once')
    parser.add_argument('--suppress-clang-output', default=False, action="store_true", help="Suppress lsif-clang's output on failure")
    parser.set_defaults(fail_fast=True)
    args = parser.parse_args()

    assert(os.path.exists(args.lsif_clang_path))
    lsif_clang_path = pathlib.Path(args.lsif_clang_path)
    if not lsif_clang_path.is_absolute():
        lsif_clang_path = pathlib.Path.cwd().joinpath(lsif_clang_path)

    workdir = pathlib.Path(args.compile_commands_path).parent
    if not workdir.is_absolute():
        workdir = pathlib.Path.cwd().joinpath(workdir)

    jobs = []
    with open(args.compile_commands_path) as f:
        entries = json.load(f)
        for (i, entry) in enumerate(entries):
            # Overwrite the working directory so that we can create
            # temporary compile_commands.json elsewhere and still have
            # everything else work as-is.
            entry['command'] += ' -working-directory={}'.format(workdir)
            jobs.append(entry)
    
    concurrency = min(args.concurrency, len(jobs))

    mp.set_start_method('spawn')
    status_queue = mp.Queue()
    sema = mp.Semaphore(value=concurrency)

    def drain_queue(q):
        count = 0
        while not q.empty(): # Did any processes complete?
            exitcode, output, compile_commands_abspath = q.get()
            if exitcode != 0:
                tmpdir = tempfile.mkdtemp('-repro')
                json_copy = '{}/compile_commands.json'.format(tmpdir)
                shutil.copyfile(compile_commands_abspath, json_copy)
                print(failure_message(output, str(lsif_clang_path), json_copy, args.suppress_clang_output),
                      file=sys.stderr)
                count += 1
                if args.fail_fast:
                    sys.exit(1)
        return count
    
    num_failures = 0

    with tempfile.TemporaryDirectory('-bisect-lsif-clang') as tempdir:
        shutil.rmtree(tempdir)
        os.mkdir(tempdir)
        for (i, job) in enumerate(jobs):
            sema.acquire() # TODO: Add timeout here
            num_failures += drain_queue(status_queue)
            os.mkdir('{}/{}'.format(tempdir, i))
            json_file_path = '{}/{}/compile_commands.json'.format(tempdir, i)
            with open(json_file_path, 'w') as json_file:
                json.dump([job], json_file)
            proc = mp.Process(target=run_lsif_clang, args=(status_queue, sema, str(lsif_clang_path), json_file_path))
            proc.start()
    
        for _ in range(args.concurrency):
            # Make sure to wait for any processes that were spawned at the end
            sema.acquire()
            num_failures += drain_queue(status_queue)

    # There seems to be an off-by-one error sometimes in counting failures,
    # not sure why. I would expect that there is no reordering between the
    # semaphore and queue operations, but maybe that's allowed?
    if num_failures > 0:
        print('{}/{} lsif-clang commands failed. 😭'.format(num_failures, len(jobs)))
    else:    
        print('All lsif-clang commands ran successfully! 🎉')

if __name__ == '__main__':
    default_main()
