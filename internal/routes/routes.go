package routes

import (
	"github.com/gin-gonic/gin"

	"go-gin-project/internal/handlers/profile"
	"go-gin-project/internal/middleware"
	"firebase.google.com/go/v4/auth"
)

// SetupRoutes configures all routes for the application
func SetupRoutes(router *gin.Engine, authClient *auth.Client) {
	// Public routes
	router.GET("/public", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "This is a public endpoint"})
	})

	// Protected routes
	protected := router.Group("/api")
	protected.Use(middleware.AuthMiddleware(authClient))
	{
		protected.GET("/profile", profile.ProfileHandler)
		// Add more protected routes here
	}
}
