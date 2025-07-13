package metrics

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"net/http"
)

var RequestCount = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "http_requests_total",
		Help: "Total number of requests",
	},
	[]string{"method", "path"},
)

func Register() {
	prometheus.MustRegister(RequestCount)
	http.Handle("/metrics", promhttp.Handler())
}
