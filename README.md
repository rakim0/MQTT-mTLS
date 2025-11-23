# MQTT Security Demo Project

This project demonstrates MQTT communication with both insecure and secure (mutual TLS) configurations. It includes publisher and subscriber clients for both modes.

## 📋 Prerequisites

-   Python 3.x
-   Mosquitto MQTT broker
-   OpenSSL (for certificate generation)
-   Root/sudo access (for broker configuration)

### Operating System Requirements

-   **Linux/macOS**: Full support for both insecure and mutual TLS modes
-   **macOS**: Uses Homebrew for package management
-   **Linux**: Uses systemd for service management

## 🔧 Installation

### 1. Install Mosquitto Broker

**macOS:**

```bash
brew install mosquitto
brew services start mosquitto
```

**Linux (Ubuntu/Debian):**

```bash
sudo apt-get update
sudo apt-get install mosquitto mosquitto-clients
sudo systemctl enable mosquitto
sudo systemctl start mosquitto
```

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

Or manually:

```bash
pip install paho-mqtt==2.1.0
```

## 🚀 Usage

This project has two modes of operation:

### Mode 1: Insecure MQTT (No Encryption)

Use this mode for testing and debugging. **Not recommended for production.**

#### Step 1: Start Insecure Broker

```bash
chmod +x start_insecure_broker.sh
./start_insecure_broker.sh
```

This will:

-   Configure Mosquitto to listen on port **1883**
-   Enable anonymous connections
-   Disable TLS encryption

#### Step 2: Run Subscriber (in one terminal)

```bash
python3 mqtt_insecure_sub.py
```

#### Step 3: Run Publisher (in another terminal)

```bash
python3 mqtt_insecure_pub.py
```

**Configuration:**

-   Subscriber connects to `localhost:1883`
-   Publisher connects to `10.23.106.20:1883` (update this IP as needed)
-   Topic: `mutual/test`

---

### Mode 2: Secure MQTT with Mutual TLS

Use this mode for production environments requiring strong authentication and encryption.

#### Step 1: Generate Certificates

Run the certificate generation and broker setup script:

```bash
chmod +x secure_mqtt_setup.sh
./secure_mqtt_setup.sh
```

This will:

1. Create a Certificate Authority (CA)
2. Generate server certificates (for the broker)
3. Generate client certificates (for publishers/subscribers)
4. Configure Mosquitto for mutual TLS on port **8883**
5. Restart the broker

**Certificates will be created in:** `~/mqtt_mutual_tls/`

**Important:** You will be prompted to create a passphrase for the CA key. Remember this passphrase as you'll need it during certificate signing.

#### Step 2: Copy Client Certificates to Project Directory

```bash
cp ~/mqtt_mutual_tls/ca.crt .
cp ~/mqtt_mutual_tls/client.crt .
cp ~/mqtt_mutual_tls/client.key .
```

#### Step 3: Update Broker Address

Edit both `mqtt_mutual_tls_pub.py` and `mqtt_mutual_tls_sub.py`:

```python
BROKER = "YOUR_BROKER_IP_OR_HOSTNAME"  # Change to actual IP or hostname
```

Replace with:

-   `localhost` for local testing
-   Your server's IP address for remote connections
-   Your server's hostname (must match the certificate CN if using hostname)

#### Step 4: Run Subscriber (in one terminal)

```bash
python3 mqtt_mutual_tls_sub.py
```

#### Step 5: Run Publisher (in another terminal)

```bash
python3 mqtt_mutual_tls_pub.py
```

**Configuration:**

-   Both connect to port **8883** (secure)
-   Requires valid client certificates
-   Uses TLS 1.2
-   Topic: `mutual/test`

## 📁 Project Structure

```
.
├── README.md                      # This file
├── requirements.txt               # Python dependencies
├── start_insecure_broker.sh      # Script to start insecure broker
├── secure_mqtt_setup.sh          # Script to generate certs and configure mTLS
├── mqtt_insecure_pub.py          # Insecure publisher client
├── mqtt_insecure_sub.py          # Insecure subscriber client
├── mqtt_mutual_tls_pub.py        # Secure publisher with mutual TLS
└── mqtt_mutual_tls_sub.py        # Secure subscriber with mutual TLS
```

## 🔍 Testing & Verification

### Test Insecure Connection

```bash
# Subscribe
mosquitto_sub -h localhost -p 1883 -t mutual/test

# Publish (in another terminal)
mosquitto_pub -h localhost -p 1883 -t mutual/test -m "test message"
```

### Test Secure Connection with Mutual TLS

```bash
# Subscribe
mosquitto_sub -h localhost -p 8883 -t mutual/test \
  --cafile ~/mqtt_mutual_tls/ca.crt \
  --cert ~/mqtt_mutual_tls/client.crt \
  --key ~/mqtt_mutual_tls/client.key

# Publish (in another terminal)
mosquitto_pub -h localhost -p 8883 -t mutual/test -m "secure test" \
  --cafile ~/mqtt_mutual_tls/ca.crt \
  --cert ~/mqtt_mutual_tls/client.crt \
  --key ~/mqtt_mutual_tls/client.key
```

### Check Broker Status

```bash
# Linux
sudo systemctl status mosquitto

# macOS
brew services list | grep mosquitto

# Check listening ports
sudo netstat -tlnp | grep mosquitto   # Linux
sudo lsof -i -P | grep mosquitto      # macOS
```

## 🔐 Security Notes

### Insecure Mode (Port 1883)

-   ⚠️ **No encryption** - all data transmitted in plaintext
-   ⚠️ **No authentication** - anyone can connect
-   ⚠️ **Use only for testing or local demos**
-   Good for Wireshark packet analysis demonstrations

### Mutual TLS Mode (Port 8883)

-   ✅ **Full encryption** using TLS 1.2
-   ✅ **Mutual authentication** - both client and server verify each other
-   ✅ **Certificate-based identity** - clients identified by their certificates
-   ✅ **Production-ready** security

## 🐛 Troubleshooting

### Issue: "Import paho.mqtt.client could not be resolved"

**Solution:** Install the paho-mqtt package:

```bash
pip install paho-mqtt==2.1.0
```

### Issue: "Connection refused" on port 8883

**Solution:**

1. Check if Mosquitto is running: `sudo systemctl status mosquitto`
2. Verify certificates are in `/etc/mosquitto/certs/`
3. Check Mosquitto logs: `sudo journalctl -u mosquitto -f`

### Issue: "Certificate verify failed"

**Solution:**

1. Ensure certificate files exist in the project directory
2. Verify certificate paths in the Python scripts
3. Check that server certificate CN matches the hostname/IP you're connecting to

### Issue: Permission denied when running scripts

**Solution:**

```bash
chmod +x start_insecure_broker.sh
chmod +x secure_mqtt_setup.sh
```

### Issue: Broker not listening on expected port

**Solution:**

```bash
# Check what's configured
sudo cat /etc/mosquitto/conf.d/*.conf

# Check what ports are active
sudo netstat -tlnp | grep mosquitto
```

## 📚 Additional Resources

-   [Mosquitto Documentation](https://mosquitto.org/documentation/)
-   [Paho MQTT Python Client](https://www.eclipse.org/paho/index.php?page=clients/python/index.php)
-   [MQTT Protocol Specification](https://mqtt.org/mqtt-specification/)
-   [OpenSSL Certificate Management](https://www.openssl.org/docs/man1.1.1/man1/openssl-req.html)

## 📝 Notes

-   The insecure subscriber connects to `localhost` while the insecure publisher connects to `10.23.106.20` - update these IPs based on your network setup
-   Certificate validity: Server and client certificates are valid for 360 days, CA certificate for 1826 days
-   The mutual TLS setup uses certificate-based authentication - username/password not required

## ⚠️ Before Running in Production

1. **Update all placeholder values:**
    - Change `YOUR_BROKER_IP_OR_HOSTNAME` in mutual TLS scripts
    - Update IP addresses in insecure scripts
2. **Secure your certificates:**
    - Store private keys securely
    - Use appropriate file permissions (600 for private keys)
    - Never commit certificates to version control
3. **Firewall configuration:**
    - Open port 8883 for secure MQTT
    - Close port 1883 if not needed

---
