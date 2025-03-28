package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/lambda"
	"github.com/aws/aws-sdk-go-v2/service/lambda/types"
)

type Input struct {
	Command string
}

func main() {
	ctx := context.Background()

	if len(os.Args) < 2 {
		log.Fatalf("missing shell command")
	}

	input := Input{Command: os.Args[1]}
	input.Command = strings.Join(os.Args[1:], " ")
	payload, err := json.Marshal(input)
	if err != nil {
		log.Fatalf("failed to marshal input: %s", err)
	}

	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Fatalf("failed to load AWS config: %s", err)
	}

	res, err := lambda.NewFromConfig(cfg).Invoke(ctx, &lambda.InvokeInput{
		FunctionName:   aws.String("lambda-shell"),
		InvocationType: types.InvocationTypeRequestResponse,
		LogType:        types.LogTypeTail,
		Payload:        payload,
	})
	if err != nil {
		log.Fatalf("failed to invoke lambda function: %s", err)
	}

	logResult, err := base64.StdEncoding.DecodeString(*res.LogResult)
	if err != nil {
		log.Fatalf("failed to decode output: %s", err)
	}

	filteredLogs := []string{}
	for _, line := range strings.Split(strings.TrimSpace(string(logResult)), "\n") {
		if strings.HasPrefix(line, "START RequestId:") || strings.HasPrefix(line, "END RequestId:") || strings.HasPrefix(line, "REPORT RequestId:") {
			continue
		}
		filteredLogs = append(filteredLogs, line)
	}

	fmt.Println(strings.Join(filteredLogs, "\n"))
}
