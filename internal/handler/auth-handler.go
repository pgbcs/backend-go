package handler

import (
	"backend-go/internal/model"
	"backend-go/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
)

// AuthHandler handles authentication requests (Login, Logout, Refresh Token)
type AuthHandler struct {
	userService service.UserService
}

// NewAuthHandler creates a new AuthHandler
func NewAuthHandler(us service.UserService) *AuthHandler {
	return &AuthHandler{userService: us}
}

// Login handles sign-in and returns a JWT token
// @Summary      User login
// @Description  Validates email/password and returns a JWT token for protected APIs
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        input  body      model.LoginRequest  true  "Login credentials"
// @Success      200    {object}  model.Response
// @Failure      401    {object}  model.Response
// @Router       /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req model.LoginRequest

	// 1. Bind JSON from request body
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, model.Response{
			Success: false,
			Message: "Invalid input data",
		})
		return
	}

	// 2. Call service to process login (verify password and generate token)
	token, err := h.userService.Login(req.Email, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, model.Response{
			Success: false,
			Message: err.Error(), // Example: "wrong password" or "user not found"
		})
		return
	}

	// 3. Return token to client
	c.JSON(http.StatusOK, model.Response{
		Success: true,
		Message: "Login successful",
		Data: gin.H{
			"access_token": token,
			"token_type":   "Bearer",
		},
	})
}