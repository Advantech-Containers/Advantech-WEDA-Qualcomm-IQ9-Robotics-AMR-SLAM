#!/bin/sh
set -eu
cd /app


set_json() {
  tmp="$(mktemp)"
  jq --arg v "$3" "$2" "$1" > "$tmp"
  cat "$tmp" > "$1"
  rm -f "$tmp"
}

DEVICE_KEY="${DEVICE_KEY:-robot_02}"

# ---- devicecfg.json ----
if [ -n "${SUBNODE_NAME:-}" ]; then
  set_json devicecfg.json '.SubNode.Name = $v' "$SUBNODE_NAME"
  echo "[entrypoint] SubNode.Name overridden"
fi

# ---- systemcfg.json ----
if [ -n "${WEDA_NODE_URL:-}" ]; then
  set_json systemcfg.json '.WedaNode.Url = $v' "$WEDA_NODE_URL"
  echo "[entrypoint] WedaNode.Url overridden"
fi
if [ -n "${WEDA_NODE_USERNAME:-}" ]; then
  set_json systemcfg.json '.WedaNode.Username = $v' "$WEDA_NODE_USERNAME"
  echo "[entrypoint] WedaNode.Username overridden"
fi
if [ -n "${WEDA_NODE_PASSWORD:-}" ]; then
  set_json systemcfg.json '.WedaNode.Password = $v' "$WEDA_NODE_PASSWORD"
  echo "[entrypoint] WedaNode.Password overridden"
fi

# ---- devicecfg.json  ----
if [ -n "${MQTT_BROKER_URL:-}" ]; then
  set_json devicecfg.json ".DeviceConfigs[\"$DEVICE_KEY\"].DeviceCommunication.BrokerUrl = \$v" "$MQTT_BROKER_URL"
  echo "[entrypoint] MQTT BrokerUrl overridden"
fi
if [ -n "${MQTT_CLIENT_ID:-}" ]; then
  set_json devicecfg.json ".DeviceConfigs[\"$DEVICE_KEY\"].DeviceCommunication.ClientId = \$v" "$MQTT_CLIENT_ID"
  echo "[entrypoint] MQTT ClientId overridden"
fi
if [ -n "${MQTT_TOPIC:-}" ]; then
  set_json devicecfg.json ".DeviceConfigs[\"$DEVICE_KEY\"].DeviceCommunication.Topic = \$v" "$MQTT_TOPIC"
  echo "[entrypoint] MQTT Topic overridden"
fi

exec /app/TestMqttSubNode "$@"
