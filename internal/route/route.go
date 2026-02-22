package route

import (
	_ "backend-go/docs"
	"backend-go/internal/handler"
	"backend-go/internal/middleware"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(userHandler *handler.UserHandler, authHandler *handler.AuthHandler) *gin.Engine {
	r := gin.Default()
	r.Use(cors.Default())
	// 1. Global Middleware
	r.Use(gin.Recovery())
	// r.Use(middleware.Logger()) 

	// 2. Swagger route
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// 3. Public routes
	v1 := r.Group("/api/v1")
	{
		v1.POST("/auth/login", authHandler.Login)
		v1.POST("/auth/register", userHandler.Register)
	}

	// 4. Private route
	protected := r.Group("/api/v1")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.GET("/profile", userHandler.GetProfile)
		// protected.PUT("/profile", userHandler.UpdateProfile)
	}

	return r
}