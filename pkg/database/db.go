package database

import (
	"backend-go/internal/config"
	model "backend-go/internal/model"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func InitDB() *gorm.DB {
	dsn := config.Envs.DBURL
	
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Unable to connect to database: ", err)
	}

	log.Println("Database connected successfully!")

	db.AutoMigrate(&model.User{})

	DB = db
	return db
}