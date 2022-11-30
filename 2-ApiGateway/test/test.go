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

	query := url.Values{
		"api-key":    {apiKey},
		"user-id":    {userId},
		"from-type":  {"Hour"},
		"to-type":    {"Second"},
		"from-value": {"1"},
	}

	url := url.URL{
		Scheme:   "https",
		Host:     domainName,
		Path:     "api/v1/convert",
		RawQuery: query.Encode(),
	}

	resp, err := http.Get(url.String())
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
