package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

func main() {
	panicOnError := func(err error) {
		if err != nil {
			panic(err)
		}
	}

	domainName := os.Getenv("API_GATEWAY_DOMAIN_NAME")
	userId := os.Getenv("NEUTRINO_USER_ID")
	apiKey := os.Getenv("NEUTRINO_API_KEY")
	fromType := "Hour"
	fromValue := "1"
	toType := "Second"

	resp, err := http.Get(fmt.Sprintf("https://%s?api-key=%s&user-id=%s&from-type=%s&from-value=%s&to-type=%s", domainName, apiKey, userId, fromType, fromValue, toType))
	panicOnError(err)

	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	panicOnError(err)

	var result struct {
		Result string `json:"result"`
	}
	err = json.Unmarshal(body, &result)
	panicOnError(err)

	const expectedContent = "3600.0"
	if !strings.Contains(result.Result, expectedContent) {
		panic(fmt.Errorf("Expected: '%s', Got: '%s'", expectedContent, result.Result))
	}

	fmt.Println("Success!")
}
