package main

import (
	"context"
	"log"

	"firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"github.com/gin-gonic/gin"
	"google.golang.org/api/option"

	"go-gin-project/internal/routes"
)

// setupFirebase initializes Firebase Admin SDK and returns auth client
func setupFirebase() *auth.Client {
	opt := option.WithCredentialsFile("reflvy-d3e67-firebase-adminsdk-fbsvc-18de96317f.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("Error initializing Firebase app: %v\n", err)
	}

	authClient, err := app.Auth(context.Background())
	if err != nil {
		log.Fatalf("Error getting Firebase Auth client: %v\n", err)
	}

	return authClient
}

func main() {
	authClient := setupFirebase()

	router := gin.Default()

	routes.SetupRoutes(router, authClient)

	log.Println("Server running on http://localhost:3000")
	router.Run(":3000")
}