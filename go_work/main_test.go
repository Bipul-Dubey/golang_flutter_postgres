package main

import (
	"bytes"
	"encoding/json"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

// get api test
func TestGetApi(t *testing.T) {
	dbConnection()
	router := gin.Default()
	router.GET("/api", getData)

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/v1", nil)
	router.ServeHTTP(w, req)

	var emp []Employee
	json.Unmarshal(w.Body.Bytes(), &emp)

	// test data
	assert.Equal(t, http.StatusOK, w.Code)
}

// post api test
func TestPostData(t *testing.T) {
	dbConnection()
	body := new(bytes.Buffer)
	writer := multipart.NewWriter(body)
	fileWriter, err := writer.CreateFormFile("resume", "test_resume.pdf")
	if err != nil {
		t.Fatal(err)
	}
	fileContents := []byte("test file contents")
	_, err = fileWriter.Write(fileContents)
	if err != nil {
		t.Fatal(err)
	}
	writer.WriteField("fullname", "Test Name")
	writer.WriteField("gender", "Male")
	writer.WriteField("from_date", "2023-06-15")
	writer.WriteField("to_date", "2022-06-25")
	writer.WriteField("number", "1234567890")
	writer.WriteField("email", "test@example.com")

	writer.Close()

	req, err := http.NewRequest("POST", "/api/v1", body)
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", writer.FormDataContentType())

	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request = req

	// Call the function being tested
	postData(c)
	assert.Equal(t, http.StatusCreated, w.Code)
}
