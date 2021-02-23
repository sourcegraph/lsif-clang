package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os/exec"

	protocol "github.com/sourcegraph/lsif-protocol"
)

func main() {
	fmt.Println("Starting test harness...")
	fmt.Println(protocol.NewDocument(1, "go", "file:///tmp/file"))

	files, err := ioutil.ReadDir("./functionaltest")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(files)
	for _, f := range files {
		fmt.Println("")
		directory := "functionaltest/" + f.Name()

		fmt.Println("Starting Directory:\t", directory)

		out, err := GenerateCompileCommands(directory)
		if err != nil {
			log.Println(out)
			log.Fatal(err)
		} else {
			fmt.Println("... Generated compile_commands.json")
		}

		out, err = GenerateLsifDump(directory)
		if err != nil {
			log.Println(out)
			log.Fatal(err)
		} else {
			fmt.Println("... Generated dump.lsif")
		}

		out, err = ValidateDump(directory)
		if err != nil {
			log.Println(out)
			log.Fatal(err)
		} else {
			fmt.Println("... Validated")
		}

		test, err := ParseTestJson(directory)
		if err != nil {
			log.Fatal("Failed:", err)
		} else {
			fmt.Println("... Read test")
		}

		success, err := RunTest(test)
		if !success {
			fmt.Println("... Failed")
		} else {
			fmt.Println("... Success")
		}
	}
}

func GenerateCompileCommands(directory string) ([]byte, error) {
	cmd := exec.Command("./get_compile_commands.sh")
	cmd.Dir = directory

	return cmd.Output()
}

func GenerateLsifDump(directory string) ([]byte, error) {
	cmd := exec.Command("lsif-clang", "compile_commands.json")
	cmd.Dir = directory

	return cmd.Output()
}

func ValidateDump(directory string) ([]byte, error) {
	// TODO: Eventually this should use the package, rather than the installed module
	//       but for now this will have to do.
	cmd := exec.Command("lsif-validate", "dump.lsif")
	cmd.Dir = directory

	return cmd.Output()
}

type Position struct {
	Line      int64 `json:"line"`
	Character int64 `json:"character"`
}

type DefinitionRequest struct {
	TextDocument string   `json:"textDocument"`
	Position     Position `json:"position"`
}

type DefinitionResponse struct{}

type DefinitionTest struct {
	Request  DefinitionRequest  `json:"request"`
	Response DefinitionResponse `json:"response"`
}

type LsifTest struct {
	DefinitionTests []DefinitionTest `json:"textDocument/definition"`
}

func ParseTestJson(directory string) (LsifTest, error) {
	contents, err := ioutil.ReadFile(directory + "/test.json")
	if err != nil {
		return LsifTest{}, err
	}

	var test LsifTest
	if err := json.Unmarshal(contents, &test); err != nil {
		return LsifTest{}, err
	}

	return test, nil
}

func RunTest(test LsifTest) (bool, error) {
	return true, nil
}
