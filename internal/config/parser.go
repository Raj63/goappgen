package config

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"

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
	switch {
	case filepath.Ext(path) == ".yaml" || filepath.Ext(path) == ".yml":
		err = yaml.Unmarshal(data, cfg)
	case filepath.Ext(path) == ".json":
		err = json.Unmarshal(data, cfg)
	default:
		err = errors.New("unsupported config format (use .yaml or .json)")
	}

	if err != nil {
		return nil, err
	}
	return cfg, nil
}
