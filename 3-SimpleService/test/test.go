package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"time"
)

type Todo struct {
	Id          int64     `json:"id"`
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"createdAt"`
	CompletedAt time.Time `json:"completedAt"`
}

var host string
var baseUrl url.URL

func init() {

	host = os.Getenv("SIMPLE_SERVICE_HOST")

	baseUrl = url.URL{
		Scheme: "https",
		Host:   host,
		Path:   "api/v1/todos",
	}

}

func panicOnError(err error) {
	if err != nil {
		panic(err)
	}
}

func main() {

	aTodo := testCreate()
	testComplete(aTodo.Id)

	fmt.Println("Success!")
}

func testCreate() Todo{
	expectedDescription := "Eat fish"
	todo, err := createTodo(expectedDescription)
	panicOnError(err)

	if todo.Id == 0{
		panic("Failed to create Todo")
	}

	if todo.Description != expectedDescription {
		log.Fatalf("Todo.Description. Expected: %q. Got: %q", expectedDescription, todo.Description)
	}

	if todo.CreatedAt.IsZero() {
		log.Fatalf("Todo.CreatedAt. Expected: Not Nil. Got: %q", todo.CreatedAt.String())
	}

	return todo
}

func testComplete(id int64){
	todo, err := completeTodo(id)
	panicOnError(err)

	if todo.CompletedAt.IsZero() {
		log.Fatalf("Todo.CompletedAt. Expected: Not Nil. Got: %q", todo.CompletedAt.String())
	}
}

func createTodo(description string) (Todo, error) {
	payload := struct {
		Description string `json:"description"`
	}{Description: description}

	json, err := json.Marshal(payload)
	if err != nil {
		return Todo{}, err
	}

	resp, err := http.Post(baseUrl.String(), "application/json", bytes.NewReader(json))
	if err != nil {
		return Todo{}, err
	}

	defer resp.Body.Close()
	var todo Todo
	err = readResponse(resp, &todo)
	if err != nil {
		return Todo{}, err
	}

	return todo, nil
}

func getTodos() ([]Todo, error) {
	resp, err := http.Get(baseUrl.String())
	if err != nil {
		return []Todo{}, nil
	}

	var todos []Todo
	err = readResponse(resp, &todos)
	if err != nil {
		return todos, nil
	}

	return todos, nil
}

func completeTodo(id int64) (Todo, error) {
	url := baseUrl.JoinPath(strconv.FormatInt(id, 10), "complete")

	req, err := http.NewRequest("PATCH", url.String(), nil)
	if err != nil{
		return Todo{}, nil
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return Todo{}, nil
	}

	var todo Todo
	err = readResponse(resp, &todo)
	if err != nil {
		return todo, nil
	}

	return todo, nil
}

func readResponse(response *http.Response, v any) error {
	body, err := io.ReadAll(response.Body)
	if err != nil {
		return err
	}

	log.Printf("Response: %q", string(body))

	err = json.Unmarshal(body, &v)
	if err != nil {
		return err
	}

	return nil
}
