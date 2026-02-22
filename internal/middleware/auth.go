package middleware

import (
	"backend-go/internal/auth"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
)

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		// Validate format: Bearer <token>
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(401, gin.H{"error": "Unauthorized"})
			c.Abort()
			return
		}

		// Call VerifyToken
		claims, err := auth.VerifyToken(parts[1])
		if err != nil {
			c.JSON(401, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}

		userIDClaim, ok := (*claims)["user_id"]
		if !ok {
			c.JSON(401, gin.H{"error": "Invalid token payload"})
			c.Abort()
			return
		}

		var userID uint64
		switch value := userIDClaim.(type) {
		case float64:
			userID = uint64(value)
		case string:
			parsed, err := strconv.ParseUint(value, 10, 64)
			if err != nil {
				c.JSON(401, gin.H{"error": "Invalid token payload"})
				c.Abort()
				return
			}
			userID = parsed
		default:
			c.JSON(401, gin.H{"error": "Invalid token payload"})
			c.Abort()
			return
		}

		// Store user info in context for downstream handlers
		c.Set("user_id", uint(userID))
		c.Next()
	}
}
