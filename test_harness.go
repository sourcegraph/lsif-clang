package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os/exec"
)

func main() {
	fmt.Println("Starting test harness...")

	files, err := ioutil.ReadDir("./functionaltest")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(files)
	for _, f := range files {
		directory := "functionaltest/" + f.Name()
		err := GenerateLsifDump(directory)
		if err != nil {
			log.Fatal(err)
		}
	}
}

func GenerateCompileCommands(directory string) error {
	fmt.Println("Generating compile commands for:\t", directory)
	cmd := exec.Command("./get_compile_commands.sh")
	cmd.Dir = directory

	_, err := cmd.Output()

	// if err != nil {
	// 	fmt.Println(err)
	// } else {
	// 	fmt.Printf("%s", out)
	// }

	return err
}

func GenerateLsifDump(directory string) error {
	err := GenerateCompileCommands(directory)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Generating dump.lsif")

	return nil
}
