package handler

import (
	"backend-go/internal/model"
	"backend-go/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
)

// UserHandler represents the controller that handles user-related requests
type UserHandler struct {
	userService service.UserService
}

// NewUserHandler is the constructor for UserHandler
func NewUserHandler(us service.UserService) *UserHandler {
	return &UserHandler{userService: us}
}

// Register handles new user registration requests
// @Summary      User registration
// @Description  Create a new account with email and password
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        input  body      model.CreateUserRequest  true  "Registration details"
// @Success      201    {object}  model.Response
// @Failure      400    {object}  model.Response
// @Failure      500    {object}  model.Response
// @Router       /auth/register [post]
func (h *UserHandler) Register(c *gin.Context) {
	var req model.CreateUserRequest

	// 1. Bind & validate input data (Email, password length...)
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, model.Response{
			Success: false,
			Message: "Invalid input data: " + err.Error(),
		})
		return
	}

	// 2. Call service layer to execute business logic
	user, err := h.userService.Register(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, model.Response{
			Success: false,
			Message: err.Error(),
		})
		return
	}

	// 3. Return success result using standard response format
	c.JSON(http.StatusCreated, model.Response{
		Success: true,
		Message: "Registration successful",
		Data:    user,
	})
}

// GetProfile returns the profile of the current user (JWT required)
// @Summary      View profile
// @Description  Retrieve detailed information of the currently logged-in user
// @Tags         User
// @Security     BearerAuth
// @Produce      json
// @Success      200    {object}  model.Response
// @Router       /user/profile [get]
func (h *UserHandler) GetProfile(c *gin.Context) {
	// Get userID from context (set by auth middleware after JWT verification)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, model.Response{
			Success: false,
			Message: "Authentication information not found",
		})
		return
	}

	// Cast userID to uint (depends on how user_id is stored in JWT)
	user, err := h.userService.GetUserByID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, model.Response{
			Success: false,
			Message: "User not found",
		})
		return
	}

	c.JSON(http.StatusOK, model.Response{
		Success: true,
		Data:    user,
	})
}