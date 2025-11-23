import paho.mqtt.client as mqtt
import ssl

BROKER = "10.114.25.138"
PORT = 8883
TOPIC = "mutual/test"

print("[1] Creating MQTT client")
client = mqtt.Client(client_id="subscriber1")

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
    print(f"[4] Subscribing to topic '{TOPIC}' …")
    client.subscribe(TOPIC)


def on_message(client, userdata, msg):
    print(f"[5] Received message: topic={msg.topic}, payload={msg.payload.decode()}")


client.on_connect = on_connect
client.on_message = on_message

print("[6] Connecting to broker …")
client.connect(BROKER, PORT, keepalive=60)
print("[7] Waiting for messages …")
client.loop_forever()
