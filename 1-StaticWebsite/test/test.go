package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

const expectedContent = "Hello World"

func main() {
	panicOnError := func(err error) {
		if err != nil {
			panic(err)
		}
	}

	host := os.Getenv("STATIC_WEBSITE_HOST")
	resp, err := http.Get(fmt.Sprintf("https://%s", host))
	panicOnError(err)

	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	panicOnError(err)

	actualContent := string(body)
	if !strings.Contains(actualContent, expectedContent) {
		panic(fmt.Errorf("Expected: '%s', Got: '%s'", expectedContent, actualContent))
	}

	fmt.Println("Success!")
}
