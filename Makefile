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

# Chạy migration SQL vào DB đang chạy
docker-migrate:
	docker exec -i charity-db psql -U charity_user -d charity_chain < db/migrations/001_init_schema.sql

# Kết nối psql trực tiếp vào DB
docker-psql:
	docker exec -it charity-db psql -U charity_user -d charity_chain

# Chạy seed data vào DB
docker-seed:
	Get-Content db/migrations/002_seed_data.sql | docker exec -i charity-db psql -U charity_user -d charity_chain
