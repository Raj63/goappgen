package logger

import (
	"github.com/sirupsen/logrus"
)

var Log = logrus.New()

func Init() {
	Log.SetFormatter(&logrus.TextFormatter{})
	Log.SetLevel(logrus.InfoLevel)
}
