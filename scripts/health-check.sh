#!/bin/bash

loki=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:3100/ready)

if [ "$loki" = "200" ]; then
    echo "loki: healthy"
else
    echo "loki: unhealthy"
fi

promtail=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:9080/ready)

if [ "$promtail" = "200" ]; then
    echo "promtail: healthy"
else
    echo "promtail: unhealthy"
fi

grafana=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:3000/api/health)

if [ "$grafana" = "200" ]; then
    echo "grafana: healthy"
else
    echo "grafana: unhealthy"
fi