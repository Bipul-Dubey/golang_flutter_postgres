package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"path"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Employee struct {
	ID       uint   `gorm:"primaryKey,autoIncrement,"`
	FullName string `json:"fullname" binding:"required"`
	Gender   string `json:"gender" binding:"required,alpha"`
	FromDate string `json:"from_date" binding:"required"`
	ToDate   string `json:"to_date" binding:"required"`
	Number   string `json:"number" binding:"required,numeric,min=10,max=10"`
	Email    string `json:"email" binding:"required"`
	Files    string `json:"file" binding:"required"`
}

// database
var DB *gorm.DB

func dbConnection() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	host := os.Getenv("PGHOST")
	port := os.Getenv("PGPORT")
	database := os.Getenv("POSTGRES_DB")
	user_name := os.Getenv("POSTGRES_USER")
	password := os.Getenv("POSTGRES_PASSWORD")

	db, err := gorm.Open(postgres.Open("postgres://" + user_name + ":" + password + "@" + host + ":" + port + "/" + database + "?sslmode=disable"))
	if err != nil {
		fmt.Println(err, " Database Connection Failed")
		log.Fatal("connection error: ", err)
	}
	db.AutoMigrate(&Employee{})
	DB = db
}

// api handler
// get data for GET API
func getData(c *gin.Context) {
	datas := []Employee{}
	DB.Find(&datas)
	c.JSON(http.StatusOK, &datas)
}

// save Data from POST API
func postData(c *gin.Context) {
	// get file from the request
	file, err := c.FormFile("resume")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File error - No file"})
		return
	}

	// handling file size
	maxFileSize := int64(15 * 1024 * 1024)
	if file.Size > maxFileSize {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File size exceeds the limit"})
		return
	}

	// handling file type
	file_types := map[string]int{
		".pdf": 1,
		".png": 2,
	}
	_, exists := file_types[path.Ext(file.Filename)]
	if !exists {
		c.JSON(http.StatusNotAcceptable, gin.H{"error": "File Type Error"})
		return
	}

	user_file := uuid.New().String() + "_" + file.Filename
	emp := &Employee{
		FullName: c.PostForm("fullname"),
		Gender:   c.PostForm("gender"),
		FromDate: c.PostForm("from_date"),
		ToDate:   c.PostForm("to_date"),
		Number:   c.PostForm("number"),
		Email:    c.PostForm("email"),
		Files:    user_file,
	}
	err = c.ShouldBind(&emp)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Bad request " + err.Error()})
		return
	}

	result := DB.Create(&emp)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"database error": result.Error})
		return
	}

	// Save the file
	err = c.SaveUploadedFile(file, "./files/"+user_file)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"file saveing error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, &emp)
}

// serve files
func serveFile(c *gin.Context) {
	filePath := c.Param("filepath")
	filePath = "./files/" + filePath
	c.File(filePath)
}

func main() {
	// database connection
	dbConnection()

	router := gin.Default()
	router.Use(cors.New(cors.Config{
		AllowAllOrigins: true,
		AllowMethods:    []string{"POST", "GET"},
		AllowHeaders:    []string{"Origin"},
	}))
	api := router.Group("/api/v1")
	{
		api.GET("", getData)
		api.POST("", postData)
	}

	router.GET("/file/:filepath", serveFile)

	router.Run(":8080")
}
