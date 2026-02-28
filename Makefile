.PHONY: swagger run dev docker-up docker-down docker-logs docker-db

swagger:
	swag init -g cmd/server/main.go

run:
	go run ./cmd/server/main.go

dev: swagger run

# --- Docker commands ---

# Khởi động toàn bộ stack (DB + API)
docker-up:
	docker compose up -d --build

# Chỉ khởi động DB (dùng khi dev local với `make run`)
docker-db:
	docker compose up -d db

# Dừng và xoá containers
docker-down:
	docker compose down

# Xem logs realtime
docker-logs:
	docker compose logs -f
