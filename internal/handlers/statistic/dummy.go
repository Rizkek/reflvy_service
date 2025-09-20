// internal/handlers/statistic/dummy.go
package statistic

import (
	"context"
	"math/rand"
	"net/http"
	"time"

	"go-gin-project/internal/models"

	"cloud.google.com/go/firestore"
	"github.com/gin-gonic/gin"
)

var dummyApps = []string{"tiktok", "chrome", "gallery", "instagram", "youtube", "facebook", "twitter"}

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
