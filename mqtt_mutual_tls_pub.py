import paho.mqtt.client as mqtt
import ssl
import time

BROKER = "10.23.106.20"
PORT = 8883
TOPIC = "mutual/test"

print("[1] Creating MQTT client")
client = mqtt.Client(client_id="publisher1")

print("[2] Configuring TLS with client certs")
client.tls_set(
    ca_certs="ca.crt",
    certfile="client.crt",
    keyfile="client.key",
    tls_version=ssl.PROTOCOL_TLSv1_2,
)
client.tls_insecure_set(True)


def on_connect(client, userdata, flags, rc):
    print(f"[3] Connected with result code {mqtt.error_string(rc)}")


def on_publish(client, userdata, mid):
    print(f"[5] Message published, mid={mid}")


client.on_connect = on_connect
client.on_publish = on_publish

print("[4] Connecting to broker …")
client.connect(BROKER, PORT, keepalive=60)
client.loop_start()

time.sleep(1)
print(f"[6] Publishing to topic '{TOPIC}' …")
client.publish(TOPIC, "m=random")

time.sleep(2)
client.loop_stop()
print("[7] Done.")
