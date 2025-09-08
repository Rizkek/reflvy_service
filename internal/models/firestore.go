// File: internal/models/firestore.go

package models

import "time"

// UserSettings merepresentasikan sub-dokumen 'settings' di dalam dokumen User.
type UserSettings struct {
	Notifications       bool `firestore:"notifications" json:"notifications"`
	AutoDetection       bool `firestore:"autoDetection" json:"autoDetection"`
	HighRiskOnly        bool `firestore:"highRiskOnly" json:"highRiskOnly"`
	AutoBlockOnHighRisk bool `firestore:"autoBlockOnHighRisk" json:"autoBlockOnHighRisk"`
}

// UserStats merepresentasikan sub-dokumen 'stats' di dalam dokumen User.
type UserStats struct {
	TotalDetections int `firestore:"totalDetections" json:"totalDetections"`
	ActiveDays      int `firestore:"activeDays" json:"activeDays"`
	SafetyScore     int `firestore:"safetyScore" json:"safetyScore"`
}

// User merepresentasikan dokumen dalam koleksi 'users'.
type User struct {
	UID             string       `firestore:"uid" json:"uid"`
	Email           string       `firestore:"email" json:"email"`
	FullName        string       `firestore:"fullName" json:"fullName"`
	Gender          string       `firestore:"gender" json:"gender"`
	Age             int          `firestore:"age" json:"age"`
	Phone           string       `firestore:"phone" json:"phone"`
	JoinedAt        time.Time    `firestore:"joinedAt" json:"joinedAt"`
	TermsAccepted   bool         `firestore:"termsAccepted" json:"termsAccepted"`
	TermsAcceptedAt time.Time    `firestore:"termsAcceptedAt" json:"termsAcceptedAt"`
	NewUser         bool         `firestore:"newUser" json:"newUser"`
	AvatarURL       string       `firestore:"avatarUrl,omitempty" json:"avatarUrl,omitempty"`
	Settings        UserSettings `firestore:"settings" json:"settings"`
	Stats           UserStats    `firestore:"stats" json:"stats"`
}

// TargetApp merepresentasikan dokumen dalam koleksi 'targetApps'.
type TargetApp struct {
	AppID       string            `firestore:"appId" json:"appId"`
	DisplayName string            `firestore:"displayName" json:"displayName"`
	PackageName string            `firestore:"packageName" json:"packageName"`
	Enabled     bool              `firestore:"enabled" json:"enabled"`
	RiskProfile map[string]string `firestore:"riskProfile" json:"riskProfile"`
	UpdatedAt   time.Time         `firestore:"updatedAt" json:"updatedAt"`
}

// Detection merepresentasikan dokumen dalam sub-koleksi 'detections'.
type Detection struct {
	DetectionID     string    `firestore:"detectionId" json:"detectionId"`
	AppID           string    `firestore:"appId" json:"appId"`
	AppDisplayName  string    `firestore:"appDisplayName" json:"appDisplayName"`
	StartTimestamp  time.Time `firestore:"startTimestamp" json:"startTimestamp"`
	EndTimestamp    time.Time `firestore:"endTimestamp" json:"endTimestamp"`
	DurationSeconds int       `firestore:"durationSeconds" json:"durationSeconds"`
	RiskLevel       string    `firestore:"riskLevel" json:"riskLevel"`
	Label           string    `firestore:"label" json:"label"`
	ScreenshotURL   string    `firestore:"screenshotUrl,omitempty" json:"screenshotUrl,omitempty"`
	ActionTaken     string    `firestore:"actionTaken" json:"actionTaken"`
	AIConfidence    float64   `firestore:"aiConfidence" json:"aiConfidence"`
	CreatedAt       time.Time `firestore:"createdAt" json:"createdAt"`
}

// TopApp digunakan dalam dokumen analytics.
type TopApp struct {
	AppID string `firestore:"appId" json:"appId"`
	Count int    `firestore:"count" json:"count"`
}

// DailyAnalytics merepresentasikan dokumen dalam koleksi 'analytics'.
type DailyAnalytics struct {
	Date            string   `firestore:"date" json:"date"`
	UserCount       int      `firestore:"userCount" json:"userCount"`
	DetectionsTotal int      `firestore:"detectionsTotal" json:"detectionsTotal"`
	HighRisk        int      `firestore:"highRisk" json:"highRisk"`
	TopApps         []TopApp `firestore:"topApps" json:"topApps"`
}
