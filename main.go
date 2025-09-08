// File: main.go

package main

import (
	"context"
	"log"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"github.com/gin-gonic/gin"
	"google.golang.org/api/option"

	"go-gin-project/internal/routes"
)

// setupFirebase initializes Firebase Admin SDK and returns auth and firestore clients
func setupFirebase() (*auth.Client, *firestore.Client) {
	opt := option.WithCredentialsFile("reflvy-d3e67-firebase-adminsdk-fbsvc-18de96317f.json")

	// Inisialisasi Firebase App
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("Error initializing Firebase app: %v\n", err)
	}

	// Inisialisasi Auth Client
	authClient, err := app.Auth(context.Background())
	if err != nil {
		log.Fatalf("Error getting Firebase Auth client: %v\n", err)
	}

	// Inisialisasi Firestore Client
	firestoreClient, err := app.Firestore(context.Background())
	if err != nil {
		log.Fatalf("Error getting Firestore client: %v\n", err)
	}

	return authClient, firestoreClient
}

func main() {
	authClient, firestoreClient := setupFirebase()
	defer firestoreClient.Close() // buat menutup koneksi

	router := gin.Default()

	routes.SetupRoutes(router, authClient, firestoreClient)

	log.Println("Server running on http://localhost:3000")
	router.Run(":3000")
}
