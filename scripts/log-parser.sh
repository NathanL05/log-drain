#!/bin/bash

error_log_lines=$(docker exec logdrain-generator wc -l /app/logs/error.log)
top_errors=$(docker exec logdrain-generator grep -o 'msg="[^"]*"' /app/logs/error.log | sort | uniq -c | sort -rn)
status_codes=$(docker exec logdrain-generator awk '{print $7}' /app/logs/access.log | sort | uniq -c | sort -rn)

echo "=== Error Log Line Count ==="
echo "$error_log_lines"
echo ""
echo "=== Top Errors ==="
echo "$top_errors"
echo ""
echo "=== Status Code Counts ==="
echo "$status_codes"
