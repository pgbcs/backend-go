package model

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Email     string         `gorm:"uniqueIndex;not null" json:"email"`
	Password  string         `gorm:"not null" json:"-"` // "-" to hide password from JSON responses
	FullName  string         `json:"full_name"`
	Role	  UserRole		 `json:"role"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

type CreateUserRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
	FullName string `json:"full_name" binding:"required"`
}

type LoginRequest struct{
	Email		string	`json:"email" binding:"required,email"`
	Password	string  `json:"password" binding:"required,min=8"`
}

type UserRole int

const (
    Admin UserRole = iota // 0
	Guest               // 1
	CharityOrg          // 2
	Donor               // 3
)