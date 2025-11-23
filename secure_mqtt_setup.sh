#!/bin/bash
# ----------------------------------------------------------------------------
# MQTT Mutual TLS Setup Script
# Based on Kaj Suaning’s tutorial: mutual certificate authentication for MQTT
# ----------------------------------------------------------------------------

echo "=== MQTT Mutual TLS Setup ==="

BASE_DIR="$HOME/mqtt_mutual_tls"
echo "[1] Create working directory: $BASE_DIR"
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# Step: create CA
echo "[2] Generate CA private key (with pass-phrase)"
openssl genrsa -des3 -out ca.key 2048
echo "[   ] Generate CA certificate"
openssl req -new -x509 -days 1826 -key ca.key -out ca.crt -subj "/CN=MyMQTT-CA"

# Step: server cert
echo "[3] Generate server private key"
openssl genrsa -out server.key 2048
echo "[   ] Generate server CSR"
openssl req -new -out server.csr -key server.key -subj "/CN=MQTT-BROKER"
echo "[   ] Sign server certificate using CA"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out server.crt -days 360

# Step: client cert
echo "[4] Generate client private key"
openssl genrsa -out client.key 2048
echo "[   ] Generate client CSR"
openssl req -new -out client.csr -key client.key -subj "/CN=MQTT-CLIENT"
echo "[   ] Sign client certificate using CA"
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out client.crt -days 360

# Step: configure Mosquitto
echo "[5] Configure Mosquitto broker for mutual TLS"

CERT_DIR="/etc/mosquitto/certs"
echo "Creating cert dir: $CERT_DIR"
sudo mkdir -p $CERT_DIR
sudo cp ca.crt server.crt server.key $CERT_DIR/
sudo chown mosquitto:mosquitto $CERT_DIR/*.*
sudo chmod 600 $CERT_DIR/server.key

CONF_FILE="/etc/mosquitto/conf.d/mutual_tls.conf"
echo "Writing configuration to $CONF_FILE"
sudo bash -c "cat > $CONF_FILE" <<EOF
allow_anonymous false
listener 8883
cafile $CERT_DIR/ca.crt
certfile $CERT_DIR/server.crt
keyfile $CERT_DIR/server.key
tls_version tlsv1.2
require_certificate true
use_identity_as_username true
EOF

echo "[6] Restart Mosquitto broker"
sudo systemctl restart mosquitto

echo "=== Setup complete. Certificates in $BASE_DIR. Broker listening on port 8883 ==="
