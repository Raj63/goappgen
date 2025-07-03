package shutdown

import (
	"context"
	"os"
	"os/signal"
	"syscall"
)

// SetupGracefulShutdown returns a context that is cancelled on SIGINT/SIGTERM and calls the provided cleanup function.
func SetupGracefulShutdown(cleanup func()) context.Context {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	go func() {
		<-ctx.Done()
		if cleanup != nil {
			cleanup()
		}
		stop()
		os.Exit(0)
	}()
	return ctx
} 