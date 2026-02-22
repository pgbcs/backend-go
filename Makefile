.PHONY: swagger run dev

swagger:
	swag init -g cmd/server/main.go

run:
	go run ./cmd/server/main.go

dev: swagger run
