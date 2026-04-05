#!/usr/bin/env bash

# ============================================================
# LogDrain - Log Generator
# Generates realistic fake application logs in an infinite loop
# Outputs: logs/access.log, logs/error.log, logs/auth.log
# ============================================================

set -euo pipefail

LOG_DIR="$(dirname "$0")/../logs"
mkdir -p "$LOG_DIR"

ACCESS_LOG="$LOG_DIR/access.log"
ERROR_LOG="$LOG_DIR/error.log"
AUTH_LOG="$LOG_DIR/auth.log"

METHODS=("GET" "POST" "PUT" "DELETE")
PATHS=("/api/users" "/api/orders" "/api/products" "/health" "/login" "/api/payments")
STATUS_CODES=(200 200 200 200 200 201 301 400 401 403 404 500 502 503)
USER_AGENTS=(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  "curl/7.88.1"
  "python-requests/2.28.0"
  "Googlebot/2.1 (+http://www.google.com/bot.html)"
)
ERROR_MESSAGES=(
  "database connection timeout after 30s"
  "failed to acquire lock on resource /api/payments"
  "null pointer dereference in OrderService.process()"
  "upstream service payments-svc returned 503"
  "memory allocation failed: heap exhausted"
  "SSL certificate verification failed for internal-api.svc"
)
USERNAMES=("admin" "deploy-bot" "nathan" "alice" "bob" "root" "ubuntu" "git")
IP_POOL=("10.0.0.1" "10.0.0.2" "192.168.1.50" "203.0.113.42" "198.51.100.7" "172.16.0.5")

random_element() {
    local arr=("$@")
    echo "${arr[$RANDOM % ${#arr[@]}]}"
}

random_int() {
    local min=$1
    local max=$2
    echo $(( min + RANDOM % (max - min + 1)))
}

timestamp() {
    date +"%Y-%m-%dT%H:%M:%S%z"
}

write_access_log() {
  local ip method path status bytes duration agent
  ip=$(random_element "${IP_POOL[@]}")
  method=$(random_element "${METHODS[@]}")
  path=$(random_element "${PATHS[@]}")
  status=$(random_element "${STATUS_CODES[@]}")
  bytes=$(random_int 200 15000)
  duration=$(random_int 5 850)
  agent=$(random_element "${USER_AGENTS[@]}")

  printf '%s %s [%s] "%s %s HTTP/1.1" %s %s %sms "%s"\n' \
    "$ip" "$(timestamp)" "$(timestamp)" "$method" "$path" \
    "$status" "$bytes" "$duration" "$agent" \
    >> "$ACCESS_LOG"
}

write_error_log() {
    local levels=("ERROR" "ERROR" "ERROR" "WARN" "CRITICAL")
    local level msg
    level=$(random_element "${levels[@]}")
    msg=$(random_element "${ERROR_MESSAGES[@]}")

    printf '[%s] %s app=payments-service env=production msg="%s"\n' \
    "$(timestamp)" "$level" "$msg" \
    >> "$ERROR_LOG"
}

write_auth_log() {
  local outcomes=("SUCCESS" "SUCCESS" "SUCCESS" "FAILURE" "FAILURE")
  local outcome user ip
  outcome=$(random_element "${outcomes[@]}")
  user=$(random_element "${USERNAMES[@]}")
  ip=$(random_element "${IP_POOL[@]}")

  printf '[%s] AUTH_%s user=%s ip=%s service=ssh\n' \
    "$(timestamp)" "$outcome" "$user" "$ip" \
    >> "$AUTH_LOG"
}

# --- Main loop ---
echo "LogDrain generator started. Writing to $LOG_DIR"
echo "Press Ctrl+C to stop."

while true; do
    for _ in $(seq 1 10); do
        write_access_log
    done

    if (( RANDOM % 10 < 3 )); then
        write_error_log
    fi

    write_auth_log

    sleep 1
done