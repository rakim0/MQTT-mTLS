#!/bin/bash

# -----------------------------------------------------------
# Script: start_insecure_broker.sh
# Purpose: Start Mosquitto broker in UNENCRYPTED mode (port 1883)
# WARNING: This disables TLS. Use only for testing/Wireshark demos.
# -----------------------------------------------------------

CONF_FILE="/etc/mosquitto/conf.d/insecure.conf"

echo "========================================================="
echo "      Starting INSECURE MQTT Broker (No TLS)"
echo "========================================================="

# Step 1: Create insecure config
echo "[1] Creating $CONF_FILE ..."
sudo bash -c "cat > $CONF_FILE" <<EOF
listener 1883
allow_anonymous true
EOF

# Step 2: Restart Mosquitto
echo "[2] Restarting Mosquitto ..."
sudo systemctl restart mosquitto

# Step 3: Check status
echo ""
echo "[3] Checking Mosquitto service status ..."
sudo systemctl status mosquitto --no-pager

# Step 4: Check if port 1883 is open
echo ""
echo "[4] Checking if MQTT port 1883 is active ..."
sudo netstat -tlnp | grep 1883 || echo "❌ Port 1883 NOT OPEN"

echo ""
echo "========================================================="
echo "   INSECURE MQTT Broker should now be running on :1883"
echo "   You can test with:"
echo "       mosquitto_pub -h <IP> -p 1883 -t test -m \"hello\""
echo "       mosquitto_sub -h <IP> -p 1883 -t test"
echo "========================================================="
