// internal/handlers/statistic/dummy.go
package statistic

import (
	"context"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"go-gin-project/internal/models"

	"cloud.google.com/go/firestore"
	"github.com/gin-gonic/gin"
)

var dummyApps = []string{"tiktok", "chrome", "gallery", "instagram", "youtube", "facebook", "twitter"}

// GenerateDummyStatisticHandler generates dummy statistics for a specific email (historical data)
func GenerateDummyStatisticHandler(db *firestore.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		userId := "dummyuser@gmail.com" // bisa diubah ke multi user jika mau
		startDate := time.Date(2025, 1, 1, 0, 0, 0, 0, time.UTC)
		endDate := time.Now()
		numDays := int(endDate.Sub(startDate).Hours()/24) + 1

		for i := 0; i < numDays; i++ {
			date := startDate.AddDate(0, 0, i)
			dateString := date.Format("January 2, 2006")
			emailPart := userId[:len(userId)-10] // ambil sebelum @, asumsi @gmail.com
			docID := emailPart + "_" + date.Format("2006-01-02")

			appCounts := make(map[string]models.AppStatCounter)
			grandTotal := 0
			totalLow := 0
			totalMedium := 0
			totalHigh := 0

			// random jumlah aplikasi per hari (3-6)
			appCount := rand.Intn(4) + 3
			usedApps := rand.Perm(len(dummyApps))[:appCount]
			for _, idx := range usedApps {
				app := dummyApps[idx]
				low := rand.Intn(10)
				medium := rand.Intn(5)
				high := rand.Intn(3)
				total := low + medium + high
				appCounts[app] = models.AppStatCounter{
					Total:  total,
					Low:    low,
					Medium: medium,
					High:   high,
				}
				grandTotal += total
				totalLow += low
				totalMedium += medium
				totalHigh += high
			}

			statDoc := models.StatisticDocument{
				UserID:      userId,
				Date:        dateString,
				GrandTotal:  grandTotal,
				TotalLow:    totalLow,
				TotalMedium: totalMedium,
				TotalHigh:   totalHigh,
				AppCounts:   appCounts,
			}

			_, err := db.Collection("nsfw_stats").Doc(docID).Set(context.Background(), statDoc)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed at " + docID, "detail": err.Error()})
				return
			}
		}

		c.JSON(http.StatusOK, gin.H{"message": "Dummy statistics generated successfully"})
	}
}

// GenerateTodayDummyStatisticHandler generates dummy statistics for today only with email input
func GenerateTodayDummyStatisticHandler(db *firestore.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Ambil email dari query parameter atau body
		email := c.Query("email")
		if email == "" {
			// Coba ambil dari JSON body jika query parameter kosong
			var reqBody struct {
				Email string `json:"email" binding:"required,email"`
			}
			if err := c.ShouldBindJSON(&reqBody); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Email is required (query param or JSON body)"})
				return
			}
			email = reqBody.Email
		}

		// Validasi email sederhana
		if len(email) < 5 || !strings.Contains(email, "@") {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid email format"})
			return
		}

		// Gunakan tanggal hari ini
		today := time.Now()
		dateString := today.Format("January 2, 2006")
		emailPart := email[:strings.Index(email, "@")] // ambil sebelum @
		docID := emailPart + "_" + today.Format("2006-01-02")

		appCounts := make(map[string]models.AppStatCounter)
		grandTotal := 0
		totalLow := 0
		totalMedium := 0
		totalHigh := 0

		// random jumlah aplikasi per hari (2-5 untuk hari ini)
		appCount := rand.Intn(4) + 2
		usedApps := rand.Perm(len(dummyApps))[:appCount]
		for _, idx := range usedApps {
			app := dummyApps[idx]
			low := rand.Intn(8) + 1 // 1-8 low detections
			medium := rand.Intn(4)  // 0-3 medium detections
			high := rand.Intn(2)    // 0-1 high detections
			total := low + medium + high
			appCounts[app] = models.AppStatCounter{
				Total:  total,
				Low:    low,
				Medium: medium,
				High:   high,
			}
			grandTotal += total
			totalLow += low
			totalMedium += medium
			totalHigh += high
		}

		statDoc := models.StatisticDocument{
			UserID:      email,
			Date:        dateString,
			GrandTotal:  grandTotal,
			TotalLow:    totalLow,
			TotalMedium: totalMedium,
			TotalHigh:   totalHigh,
			AppCounts:   appCounts,
		}

		_, err := db.Collection("nsfw_stats").Doc(docID).Set(context.Background(), statDoc)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create dummy data", "detail": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":     "Today's dummy statistics generated successfully",
			"email":       email,
			"date":        dateString,
			"document_id": docID,
			"data":        statDoc,
		})
	}
}
