package storage

import (
	"context"
	"os"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/aws/credentials"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

// InitS3Client initializes and returns an S3/MinIO client using config values.
func InitS3Client(ctx context.Context) (*s3.Client, error) {
	region := os.Getenv("S3_REGION")
	useSSL := os.Getenv("S3_USE_SSL") == "true"

	cfg, err := config.LoadDefaultConfig(ctx,
		config.WithRegion(region),
	)
	if err != nil {
		return nil, err
	}

	client := s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.UsePathStyle = true
		if !useSSL {
			o.HTTPClient = nil // Use default, but you can customize for no SSL
		}
	})
	return client, nil
}
