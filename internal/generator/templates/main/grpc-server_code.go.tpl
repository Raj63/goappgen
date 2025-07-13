// gRPC server setup
{{- if .Transport.GRPC }}
	var grpcServerOpts []grpc.ServerOption
	var unaryInterceptors []grpc.UnaryServerInterceptor
	// Exception handler (recovery interceptor)
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	unaryInterceptors = append(unaryInterceptors, recovery.UnaryServerInterceptor())
	{{- end }}
	// Record metrics interceptor
	{{- if .Middlewares.RecordMetrics.Enabled }}
	unaryInterceptors = append(unaryInterceptors, grpc_prometheus.UnaryServerInterceptor)
	{{- end }}
	// Rate limiter interceptor (simple global limiter)
	{{- if .Middlewares.RateLimiter.Enabled }}
	limiter := rate.NewLimiter(rate.Limit({{ .Middlewares.RateLimiter.RequestsPerSecond }}), {{ .Middlewares.RateLimiter.Burst }})
	rateLimitInterceptor := func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		if !limiter.Allow() {
			return nil, status.Errorf(codes.ResourceExhausted, "rate limit exceeded")
		}
		return handler(ctx, req)
	}
	unaryInterceptors = append(unaryInterceptors, rateLimitInterceptor)
	{{- end }}
	// Logging interceptor
	{{- if .Middlewares.Logging.Enabled }}
	logrusEntry := logrus.NewEntry(logrus.New())
	unaryInterceptors = append(unaryInterceptors, logrus_unary.NewInterceptor(logrusEntry))
	{{- end }}
	// Tracing interceptor
	{{- if .Middlewares.Tracing.Enabled }}
	unaryInterceptors = append(unaryInterceptors, opentracing.UnaryServerInterceptor())
	{{- end }}
	// Request ID interceptor (custom example)
	{{- if .Middlewares.RequestID.Enabled }}
	requestIDInterceptor := func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		md, ok := metadata.FromIncomingContext(ctx)
		if ok {
			if ids := md.Get("x-request-id"); len(ids) > 0 {
				ctx = context.WithValue(ctx, "request-id", ids[0])
			}
		}
		return handler(ctx, req)
	}
	unaryInterceptors = append(unaryInterceptors, requestIDInterceptor)
	{{- end }}
	if len(unaryInterceptors) > 0 {
		grpcServerOpts = append(grpcServerOpts, grpc_middleware.WithUnaryServerChain(unaryInterceptors...))
	}
	grpcServer := grpc.NewServer(grpcServerOpts...)
	// Register services here
	// lis, _ := net.Listen("tcp", ":9090")
	// grpcServer.Serve(lis)
	go func() {
		// TODO: Register and start gRPC server
	}()
{{- end }}
