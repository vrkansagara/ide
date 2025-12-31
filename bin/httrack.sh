#!/usr/bin/env bash
# ==========================================================
# Enterprise HTTrack Website Downloader
# HTTrack Version: 3.49-5
# ==========================================================

set -euo pipefail

# -------------------------
# Configuration Defaults
# -------------------------
HTTRACK_BIN="$(command -v httrack)"
LOG_DIR="./logs"
DATE_TAG="$(date +%Y%m%d_%H%M%S)"
MAX_CONN=5
MAX_RATE=250000     # bytes/sec (~250 KB/s)
TIMEOUT=30
RETRIES=3
MIN_DISK_MB=500

# -------------------------
# Helper Functions
# -------------------------
usage() {
    echo "Usage:"
    echo "  $0 <website_url> <output_directory>"
    echo
    echo "Example:"
    echo "  $0 https://example.com /data/backups/example"
    exit 1
}

log() {
    echo "[${DATE_TAG}] $1" | tee -a "$LOG_FILE"
}

check_binary() {
    if [[ -z "$HTTRACK_BIN" ]]; then
        echo "❌ httrack not found. Please install HTTrack 3.49-5"
        exit 2
    fi
}

check_disk_space() {
    local avail
    avail=$(df -Pm "$OUTPUT_DIR" | awk 'NR==2 {print $4}')
    if [[ "$avail" -lt "$MIN_DISK_MB" ]]; then
        echo "❌ Not enough disk space. Required: ${MIN_DISK_MB}MB"
        exit 3
    fi
}

sanitize_url() {
    WEBSITE_URL="${WEBSITE_URL%/}"
}

# -------------------------
# Argument Validation
# -------------------------
[[ $# -ne 2 ]] && usage

WEBSITE_URL="$1"
OUTPUT_DIR="$2"

check_binary
sanitize_url

mkdir -p "$OUTPUT_DIR" "$LOG_DIR"
LOG_FILE="${LOG_DIR}/httrack_$(echo "$WEBSITE_URL" | sed 's~https\?://~~;s~/~_~g')_${DATE_TAG}.log"

check_disk_space

log "HTTrack Version: $($HTTRACK_BIN --version)"
log "Target Website: $WEBSITE_URL"
log "Output Directory: $OUTPUT_DIR"

# -------------------------
# HTTrack Execution
# -------------------------
log "Starting website download..."

httrack "https://birdiebadminton.in" \
  -O "birdiebadminton.in-html" \
  --continue \
  --depth=5 \
  --ext-depth=2 \
  --sockets=5 \
  --timeout=30 \
  --retries=3 \
  --verbose

EXIT_CODE=$?

# -------------------------
# Post Execution
# -------------------------
if [[ "$EXIT_CODE" -eq 0 ]]; then
    log "✅ Download completed successfully"
else
    log "⚠️ Download completed with errors (exit code: $EXIT_CODE)"
fi

exit "$EXIT_CODE"
