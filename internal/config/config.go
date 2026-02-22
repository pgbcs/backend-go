package config

import (
	"log"

	"github.com/spf13/viper"
)

type Config struct {
	Port      string `mapstructure:"PORT"`
	JWTSecret string `mapstructure:"JWT_SECRET"`
	DBURL     string `mapstructure:"DB_URL"`
}

var Envs *Config

func LoadConfig() {
	viper.SetConfigFile(".env") // Specify exact config file
	viper.AutomaticEnv()         // Read system environment variables if available

	if err := viper.ReadInConfig(); err != nil {
		log.Println("System: .env file not found, falling back to system environment variables")
	}

	err := viper.Unmarshal(&Envs)
	if err != nil {
		log.Fatal("Failed to load configuration: ", err)
	}
}