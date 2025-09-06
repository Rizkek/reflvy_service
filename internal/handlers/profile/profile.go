package profile

import (
	"github.com/gin-gonic/gin"
	"net/http"

	"go-gin-project/internal/models"
)

func ProfileHandler(c *gin.Context) {
	uid := c.MustGet("uid").(string)
	email := c.MustGet("email").(string)
	isVerified := c.MustGet("is_verified").(bool)

	response := models.ProfileResponse{
		Message:    "Welcome " + email + "!",
		UserID:     uid,
		Email:      email,
		IsVerified: isVerified,
	}

	c.JSON(http.StatusOK, response)
}
