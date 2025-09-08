// File: internal/handlers/user/user.go

package user

import (
	"go-gin-project/internal/models"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/gin-gonic/gin"
)

// UserHandler akan menampung koneksi ke firestore.
type UserHandler struct {
	FirestoreClient *firestore.Client
}

// NewUserHandler membuat instance baru dari UserHandler.
func NewUserHandler(fs *firestore.Client) *UserHandler {
	return &UserHandler{
		FirestoreClient: fs,
	}
}

// CreateUserProfile membuat profil user baru setelah registrasi.
func (h *UserHandler) CreateUserProfile(c *gin.Context) {
	var req models.User

	// Bind JSON dari request ke struct User
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body: " + err.Error()})
		return
	}

	uid := c.MustGet("uid").(string)
	email := c.MustGet("email").(string)

	// Inisialisasi data user baru
	newUser := models.User{
		UID:           uid,
		Email:         email,
		FullName:      req.FullName,
		Gender:        req.Gender,
		Age:           req.Age,
		Phone:         req.Phone,
		JoinedAt:      time.Now(),
		TermsAccepted: req.TermsAccepted,
		NewUser:       true,
		Settings: models.UserSettings{ // Default settings
			Notifications:       true,
			AutoDetection:       true,
			HighRiskOnly:        false,
			AutoBlockOnHighRisk: true,
		},
		Stats: models.UserStats{ // Default stats
			TotalDetections: 0,
			ActiveDays:      0,
			SafetyScore:     100, // Mulai dari skor sempurna
		},
	}

	if newUser.TermsAccepted {
		newUser.TermsAcceptedAt = time.Now()
	}

	// Simpan data ke Firestore
	_, err := h.FirestoreClient.Collection("users").Doc(uid).Set(c, newUser)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user profile"})
		return
	}

	c.JSON(http.StatusCreated, newUser)
}

// GetUserProfile mengambil data profil user yang sedang login.
func (h *UserHandler) GetUserProfile(c *gin.Context) {
	uid := c.MustGet("uid").(string)

	doc, err := h.FirestoreClient.Collection("users").Doc(uid).Get(c)
	if err != nil {
		// Handle jika user tidak ditemukan
		c.JSON(http.StatusNotFound, gin.H{"error": "User profile not found"})
		return
	}

	var user models.User
	if err := doc.DataTo(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse user data"})
		return
	}

	c.JSON(http.StatusOK, user)
}
