package main

import (
	"backend-go/internal/auth"
	"backend-go/internal/config"
	"backend-go/internal/handler"
	"backend-go/internal/repository"
	"backend-go/internal/route"
	"backend-go/internal/service"
	"backend-go/pkg/database"

	_ "backend-go/docs"

	"github.com/gin-gonic/gin"
)

// @title           My Go Backend API
// @version         1.0
// @description     This is a sample backend server for the Go project.
// @termsOfService  http://swagger.io/terms/

// @contact.name   Bao
// @contact.email  support@swagger.io

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer " followed by a space and JWT token.

// @host      localhost:8073
// @BasePath  /api/v1
func main() {
	// 1. Initialize configuration (Load .env)
	config.LoadConfig()

	auth.Initialize()
	// 2. Connect to database
	db := database.InitDB()

	// 3. Initialize application layers (Dependency Injection)
	userRepo := repository.NewUserRepository(db)
	userService := service.NewUserService(userRepo)
	userHandler := handler.NewUserHandler(userService)
	authHandler := handler.NewAuthHandler(userService)

	// 4. Configure router
	r := route.SetupRouter(userHandler, authHandler)

	// Auxiliary routes (optional)
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	// 5. Start server using configured port
	r.Run(":" + config.Envs.Port)
}