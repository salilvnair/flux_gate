#!/bin/bash

create_file_if_not_exists() {
  FILE_NAME="$1"
  if [ ! -f "$FILE_NAME" ]; then
    touch "$FILE_NAME"
  fi
}

archive_app_logs() {
  LOG_DIR="/usr/local/openresty/nginx/logs"
  LOG_FILE="$LOG_DIR/flux_gate.log"
  ARCHIVE_DIR="$LOG_DIR/archive"
  DATE=$(date +"%Y-%m-%d_%H-%M-%S")
  ARCHIVED_FILE="$ARCHIVE_DIR/flux_gate_$DATE.log"

  # Create archive dir if not present
  mkdir -p "$ARCHIVE_DIR"

  # Move current log if it exists
  if [ -f "$LOG_FILE" ]; then
      mv "$LOG_FILE" "$ARCHIVED_FILE"
      echo "Archived log to: $ARCHIVED_FILE"
  else
      echo "No log file to archive."
  fi
}

flux_gate_init_conf() {
  create_file_if_not_exists "/usr/local/openresty/lualib/flux_gate/nginx/conf/fluxgate_resolver.conf"
  create_file_if_not_exists "/usr/local/openresty/lualib/flux_gate/nginx/conf/fluxgate_upstreams.conf"
}

extract_server_name() {
  NGINX_CONF="/usr/local/openresty/nginx/conf/nginx.conf"
  local server_name=$(grep -E "^\s*server_name\s+" "$NGINX_CONF" | awk '{gsub(";", ""); $1=""; print $0}' | head -n 1)
  echo $server_name
}


flux_gate_init_apis() {
  # Perform curl requests
  local server_name=$(extract_server_name)
  curl -k "https://$server_name/nginx/updateNameResolver"
  curl -k "https://$server_name/nginx/updateUpstream"
  curl -k "https://$server_name/saveConfigFile"
}

reboot_openresty() {
  archive_app_logs
  openresty -s stop
  openresty
}

start_flux_gate() {
  flux_gate_init_conf

  if pgrep -x "openresty" > /dev/null; then
    echo "OpenResty is running"
    flux_gate_init_apis
    reboot_openresty
    echo "FluxGate is up and running"
  else
    echo "OpenResty is not running"
    openresty
    flux_gate_init_apis
    reboot_openresty
    echo "FluxGate is up and running"
  fi
}

start_flux_gate
