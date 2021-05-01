# Forking Strategy

## New Forking Strategy

- Direct fork of llvm/llvm-project
  - This is an actual fork (albeit with truncated history, for dev experience)
  - Pros:
    - Patches are much simpler to apply (since it is a true fork)
    - It is possible to easily change _particular_ aspects of the LLVM infrastructure to better suit our needs.
    - Can be built by linking against LLVM libraries (and in the future, via source)
  - Cons:
    - Not always obvious what code is sourcegraphs or not.
      - We are attempting to mitigate this by marking down sourcegraph changes that are _within_ the LLVM source code.
      - Other code changes will live in separate folders so that the changes are obvious to developers.

We will provide the exact same commands, dockerfiles and scripts so that this appears to be a drop-in replacement for
anyone using the original `lsif-clang` strategy.

However, this will provide us with a much better way of keeping up with LLVM's new release cycle and give us all the flexibility we
need in the future for any modifications we make.

Lastly, this makes the possibility of eventually merging this in to LLVM more likely ( from 0% to 1% perhaps :laugh: )

## Original `lsif-clang` Strategy
  - Maintain LLVM "fork" with modified source and new files.
  - Pros:
    - Allowed us to have small build times, small git history, yet still make small modifications to LLVM code without having to re-implement or hack together other solutions.
    - Built by linking against LLVM libraries installed on the build machine.
  - Cons:
    - Very difficult to maintain upstream changes since git patches do not apply cleanly
    - Git history is not obvious because of non-standard layout

## Considered, but Rejected, Strategies

- New project exclusively linking against LLVM
  - Pros:
    - No upstream patches to apply
    - Easier to understand, since all code in repo is ours
  - Cons:
    - Some changes are very difficult to make because they are to parts of LLVM that are not exposed.
      - This means that we'd have to either copy the entire callstack up to that point to make one modification or attempt to hack together some other solution via LD_PRELOAD or similar.
      - This would leave to unsustainable changes and very weird behavior.
  - Example: https://github.com/tjdevries/lsif-clang-tmp
    - You can see an example of the strategy here, although we did not finish it because we ran into some difficulties.
    - For example, when trying to modify some behaviors of the SymbolCollector, it resulted in attempts to copy / inherit / override a lot of LLVM code, which seemed like it would end up being a large maintainence burden.

