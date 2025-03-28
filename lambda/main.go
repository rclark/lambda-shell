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
		if err != nil {
			return err
		}

		fmt.Println(string(output))
		return nil
	})
}
