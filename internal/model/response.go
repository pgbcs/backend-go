package model

type Response struct {
    Success bool         `json:"status_code"`
    Message    string      `json:"message"`
    Data       interface{} `json:"data,omitempty"`
}

type ErrorResponse struct {
    Success bool   `json:"success"`
    Message string `json:"message"`
    Code    int    `json:"code"` 
}