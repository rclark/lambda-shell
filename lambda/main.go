package main

import (
	"context"
	"fmt"
	"os/exec"

	"github.com/aws/aws-lambda-go/lambda"
)

type Input struct {
	Command string
}

func main() {
	lambda.Start(func(ctx context.Context, input Input) error {
		cmd := exec.Command("sh", "-c", input.Command)
		output, err := cmd.CombinedOutput()

		fmt.Println(string(output))

		if ee, ok := err.(*exec.ExitError); ok {
			fmt.Println("\033[31mError:\033[0m", string(ee.Error()))
			return nil
		}

		return err
	})
}
