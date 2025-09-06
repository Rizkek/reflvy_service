package models

// ProfileResponse represents the response for profile endpoint
type ProfileResponse struct {
	Message    string `json:"message"`
	UserID     string `json:"user_id"`
	Email      string `json:"email"`
	IsVerified bool   `json:"is_verified"`
}
