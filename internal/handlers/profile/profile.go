// internal/handlers/profile/profile.go

package profile

import (
	"context"
	"net/http"

	"go-gin-project/internal/models"

	"cloud.google.com/go/firestore"
	"github.com/gin-gonic/gin"
)

func ProfileHandler(db *firestore.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		uid := c.MustGet("uid").(string)
		email := c.MustGet("email").(string)
		isVerified := c.MustGet("is_verified").(bool)

		// Ambil data tambahan dari Firestore
		doc, err := db.Collection("users").Doc(uid).Get(context.Background())

		var userDetails models.UserDetails
		if err == nil {
			// Jika dokumen ditemukan, map data ke struct
			doc.DataTo(&userDetails)
		}

		response := models.ProfileResponse{
			Message:    "Welcome " + email + "!",
			UserID:     uid,
			Email:      email,
			IsVerified: isVerified,
			Gender:     userDetails.Gender, // Tambahkan data dari Firestore
			Age:        userDetails.Age,    // Tambahkan data dari Firestore
		}

		c.JSON(http.StatusOK, response)
	}
}
