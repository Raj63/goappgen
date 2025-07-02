package config

import (
	"encoding/json"
	"os"

	"gopkg.in/yaml.v3"
)

// LoadConfig loads an AppConfig from the given YAML or JSON file path.
// It returns the parsed configuration or an error if loading fails.
func LoadConfig(path string) (*AppConfig, error) {
	// #nosec G304
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	cfg := &AppConfig{}
	if yaml.Unmarshal(data, cfg) == nil {
		return cfg, nil
	}

	if json.Unmarshal(data, cfg) == nil {
		return cfg, nil
	}

	return nil, err
}
