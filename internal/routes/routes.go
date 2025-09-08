// File: internal/routes/routes.go

package routes

import (
	"cloud.google.com/go/firestore"
	"firebase.google.com/go/v4/auth"
	"github.com/gin-gonic/gin"

	"go-gin-project/internal/handlers/profile"
	"go-gin-project/internal/handlers/user" // Import user handler
	"go-gin-project/internal/middleware"
)

// SetupRoutes configures all routes for the application
func SetupRoutes(router *gin.Engine, authClient *auth.Client, firestoreClient *firestore.Client) { // Tambahkan firestoreClient
	// Public routes
	router.GET("/public", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "This is a public endpoint"})
	})

	// Inisialisasi handler
	userHandler := user.NewUserHandler(firestoreClient)

	// Protected routes
	protected := router.Group("/api")
	protected.Use(middleware.AuthMiddleware(authClient))
	{
		protected.GET("/profile", profile.ProfileHandler)

		// Rute baru untuk User
		protected.POST("/user", userHandler.CreateUserProfile) // Membuat profil user
		protected.GET("/user", userHandler.GetUserProfile)     // Mendapatkan profil user
		// Nanti bisa ditambahkan: protected.PUT("/user", userHandler.UpdateUserProfile)
	}
}
