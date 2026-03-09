#!/bin/bash

USER_A="nachr"
USER_B="nachr-dev"

SERVICE_WIFI="Wi-Fi"
SERVICE_LAN="USB 2.5G LAN"

CURRENT_USER=$(stat -f %Su /dev/console)

ALL_SERVICES=()
while IFS= read -r line; do
  ALL_SERVICES+=("$line")
done < <(
  /usr/sbin/networksetup -listallnetworkservices \
  | tail -n +2 \
  | sed 's/^\* //'
)

build_order() {
  local first="$1"
  local second="$2"

  local result=()
  result+=("$first")
  result+=("$second")

  for svc in "${ALL_SERVICES[@]}"; do
    if [[ "$svc" != "$first" && "$svc" != "$second" ]]; then
      result+=("$svc")
    fi
  done

  printf "%s\n" "${result[@]}"
}

apply_order() {

  local first="$1"
  local second="$2"

  ORDER=()
  while IFS= read -r line; do
    ORDER+=("$line")
  done < <(build_order "$first" "$second")

  echo "Switching order to: ${ORDER[*]}"

  /usr/sbin/networksetup -ordernetworkservices "${ORDER[@]}"
}

case "$CURRENT_USER" in
  "$USER_A")
    apply_order "$SERVICE_WIFI" "$SERVICE_LAN"
    ;;
  "$USER_B")
    apply_order "$SERVICE_LAN" "$SERVICE_WIFI"
    ;;
  *)
    echo "No rule for user $CURRENT_USER"
    ;;
esac
