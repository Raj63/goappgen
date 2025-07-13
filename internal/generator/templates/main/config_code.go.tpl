{{- if eq .Config.Type "viper" }}
viper.SetConfigName("config")
viper.AddConfigPath(".")
if err := viper.ReadInConfig(); err != nil {
	panic(fmt.Errorf("fatal config error: %w", err))
}
{{- else if eq .Config.Type "envconfig" }}
var cfg Config
if err := envconfig.Process("", &cfg); err != nil {
	panic(fmt.Errorf("fatal config error: %w", err))
}
{{- end }}
