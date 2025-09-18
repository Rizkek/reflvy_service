package detectnsfw

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"mime/multipart"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/gin-gonic/gin"
)

// DetectionResult represents a single detection result from the API
type DetectionResult struct {
	Box   []int   `json:"box"`
	Class string  `json:"class"`
	Score float64 `json:"score"`
}

// APIResponse represents the response from the external NSFW detection API
type APIResponse struct {
	Filename string            `json:"filename"`
	Results  []DetectionResult `json:"results"`
	Status   string            `json:"status"`
}

// StatisticDocument represents the document structure for statistics collection
type StatisticDocument struct {
	Email       string    `firestore:"email"`
	Application string    `firestore:"application"`
	Result      time.Time `firestore:"result"`
	Risk        int       `firestore:"risk"`
}

// classifyNSFW classifies the NSFW level based on detection results using updated standards
func classifyNSFW(results []DetectionResult) int {
	// Initialize counters for exposed areas
	exposedCount := 0
	hasHighExposed := false

	femaleBreastExposed := 0.0
	femaleGenitaliaExposed := 0.0
	maleGenitaliaExposed := 0.0
	anusExposed := 0.0
	bellyExposed := 0.0
	buttocksExposed := 0.0
	armpitsExposed := 0.0
	feetExposed := 0.0
	femaleBreastCovered := 1.0 // Default high if not detected

	for _, r := range results {
		switch r.Class {
		case "FEMALE_BREAST_EXPOSED":
			femaleBreastExposed = r.Score
			if r.Score >= 0.5 {
				hasHighExposed = true
			}
			if r.Score >= 0.2 {
				exposedCount++
			}
		case "FEMALE_GENITALIA_EXPOSED":
			femaleGenitaliaExposed = r.Score
			if r.Score >= 0.5 {
				hasHighExposed = true
			}
			if r.Score >= 0.2 {
				exposedCount++
			}
		case "MALE_GENITALIA_EXPOSED":
			maleGenitaliaExposed = r.Score
			if r.Score >= 0.5 {
				hasHighExposed = true
			}
			if r.Score >= 0.2 {
				exposedCount++
			}
		case "ANUS_EXPOSED":
			anusExposed = r.Score
			if r.Score >= 0.5 {
				hasHighExposed = true
			}
			if r.Score >= 0.2 {
				exposedCount++
			}
		case "BELLY_EXPOSED":
			bellyExposed = r.Score
			if r.Score >= 0.3 {
				exposedCount++
			}
		case "BUTTOCKS_EXPOSED":
			buttocksExposed = r.Score
			if r.Score >= 0.3 {
				exposedCount++
			}
		case "ARMPITS_EXPOSED":
			armpitsExposed = r.Score
			if r.Score >= 0.3 {
				exposedCount++
			}
		case "FEET_EXPOSED":
			feetExposed = r.Score
		case "FEMALE_BREAST_COVERED":
			if r.Score < femaleBreastCovered {
				femaleBreastCovered = r.Score
			}
		}
	}

	// Check for category 4: high NSFW (explicit)
	if hasHighExposed || exposedCount > 2 {
		return 3
	}

	// Check for category 3: moderate NSFW (minimal clothing)
	if buttocksExposed >= 0.5 || (bellyExposed >= 0.5 && femaleBreastCovered < 0.4) {
		if femaleBreastExposed < 0.5 && femaleGenitaliaExposed < 0.3 && maleGenitaliaExposed < 0.3 && anusExposed < 0.3 {
			return 2
		}
	}

	// Check for category 2: mild NSFW (casual sensual)
	if (bellyExposed >= 0.5 || armpitsExposed >= 0.5 || feetExposed >= 0.5) && femaleBreastCovered >= 0.4 {
		if femaleBreastExposed < 0.3 && femaleGenitaliaExposed < 0.3 && maleGenitaliaExposed < 0.3 && anusExposed < 0.3 {
			return 1
		}
	}

	// Check for category 1: not NSFW (safe)
	if femaleBreastExposed < 0.2 && femaleGenitaliaExposed < 0.2 && maleGenitaliaExposed < 0.2 && anusExposed < 0.2 &&
		bellyExposed < 0.3 && buttocksExposed < 0.3 && armpitsExposed < 0.3 {
		return 0
	}

	// Default to mild if no clear category
	return 1
}

func DetectNSFWHandler(db *firestore.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Parse multipart form
		file, header, err := c.Request.FormFile("image")
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Image file is required"})
			return
		}
		defer file.Close()

		// Get application parameter from form
		application := c.PostForm("application")
		if application == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Application parameter is required"})
			return
		}

		// Get user email from context (set by auth middleware)
		email, exists := c.Get("email")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User email not found in context"})
			return
		}
		userEmail := email.(string)

		// Read the file content
		fileBytes, err := io.ReadAll(file)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read image file"})
			return
		}

		// Create a new multipart form for forwarding
		body := &bytes.Buffer{}
		writer := multipart.NewWriter(body)

		// Add the image file to the new form
		part, err := writer.CreateFormFile("image", header.Filename)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create form file"})
			return
		}
		part.Write(fileBytes)
		writer.Close()

		// Forward the request to the external service
		req, err := http.NewRequest("POST", "http://127.0.0.1:5000/detect", body)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
			return
		}
		req.Header.Set("Content-Type", writer.FormDataContentType())

		client := &http.Client{}
		resp, err := client.Do(req)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to forward request"})
			return
		}
		defer resp.Body.Close()

		// Read the response from the external service
		respBody, err := io.ReadAll(resp.Body)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
			return
		}

		// Parse the JSON response
		var apiResp APIResponse
		if err := json.Unmarshal(respBody, &apiResp); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse API response"})
			return
		}

		// Classify NSFW level
		nsfwLevel := classifyNSFW(apiResp.Results)

		// If NSFW level > 0, save to Firestore
		if nsfwLevel > 0 {
			statDoc := StatisticDocument{
				Email:       userEmail,
				Application: application,
				Result:      time.Now(),
				Risk:        nsfwLevel,
			}

			_, err = db.Collection("statistic").NewDoc().Set(context.Background(), statDoc)
			if err != nil {
				// Log error but don't fail the request
				// You could add proper logging here
			}
		}

		// Return the classification result along with original detection results
		c.JSON(http.StatusOK, gin.H{
			"filename":          apiResp.Filename,
			"nsfw_level":        nsfwLevel,
			"detection_results": apiResp.Results,
			"status":            "success",
		})
	}
}
