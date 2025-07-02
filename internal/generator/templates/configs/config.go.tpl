package config

import (
	"github.com/spf13/viper"
)

func Load() error {
	viper.SetConfigName("config")
	viper.AddConfigPath(".")

	return viper.ReadInConfig()
}
