#!/usr/bin/env bash

set -u

STACK_ID="${STACK_ID:-}"
MAX_RETRIES="${MAX_RETRIES:-100}"
RETRY_DELAY="${RETRY_DELAY:-30}"
DISPLAY_NAME="${DISPLAY_NAME:-Agent Host Deploy}"

if [ -z "$STACK_ID" ]; then
  echo "STACK_ID is required."
  echo "Usage: STACK_ID=<stack_ocid> ./auto-deploy.sh"
  exit 2
fi

echo "=========================================="
echo "OCI Resource Manager Apply Retry"
echo "=========================================="
echo "Stack ID: $STACK_ID"
echo "Max retries: $MAX_RETRIES"
echo "Retry delay: ${RETRY_DELAY}s"
echo ""

for attempt in $(seq 1 "$MAX_RETRIES"); do
  echo "----------------------------------------"
  echo "Attempt $attempt/$MAX_RETRIES - $(date '+%Y-%m-%d %H:%M:%S')"
  echo "----------------------------------------"

  job_output=$(oci resource-manager job create-apply-job \
    --stack-id "$STACK_ID" \
    --display-name "$DISPLAY_NAME #$attempt" \
    --execution-plan-strategy AUTO_APPROVED \
    --wait-for-state SUCCEEDED \
    --wait-for-state FAILED 2>&1)

  job_id=$(printf '%s\n' "$job_output" | grep -o '"id": "ocid1.ormjob[^"]*' | head -1 | cut -d'"' -f4)
  job_state=$(printf '%s\n' "$job_output" | grep -o '"lifecycle-state": "[^"]*' | head -1 | cut -d'"' -f4)

  echo "Job ID: ${job_id:-unknown}"
  echo "State: ${job_state:-unknown}"

  if [ "$job_state" = "SUCCEEDED" ]; then
    echo ""
    echo "Apply succeeded."
    echo "Check stack outputs in the OCI Console or with:"
    echo "  oci resource-manager stack get-stack-tf-state --stack-id $STACK_ID"
    exit 0
  fi

  if [ -n "$job_id" ]; then
    echo ""
    echo "Recent errors:"
    oci resource-manager job get-job-logs \
      --job-id "$job_id" \
      --all 2>/dev/null | grep -Ei "error|capacity|limit" | tail -5 || true
  else
    echo "$job_output" | tail -20
  fi

  if [ "$attempt" -lt "$MAX_RETRIES" ]; then
    echo ""
    echo "Retrying in ${RETRY_DELAY}s..."
    sleep "$RETRY_DELAY"
  fi
done

echo ""
echo "Failed after $MAX_RETRIES attempts."
echo "Try another availability domain, reduce OCPU/memory, or retry later."
exit 1
