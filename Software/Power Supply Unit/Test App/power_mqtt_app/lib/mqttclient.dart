import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientWrapper {
  MqttServerClient client;

  void prepareMqttClient() async {
    _setupMqttClient();
    await _connect();
  }

  void publishMessage(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print(
        'MQTTClientWrapper::Publishing message $message to topic "esp8266/test1"');
    client.publishMessage(
        "esp8266/test1", MqttQos.atLeastOnce, builder.payload,
        retain: true);
  }

  Future<MqttServerClient> _connect() async {
    try {
      print('MQTTClientWrapper::EMQ client connecting....');
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    print('MQTTClientWrapper::Subscribing to the "esp8266/test1" topic');
    client.subscribe('esp8266/test1', MqttQos.atLeastOnce);

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message:$payload from topic: ${c[0].topic}>');
    });

    return client;
  }

  void _setupMqttClient() {
    client =
        MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;

    /*
    final connMessage = MqttConnectMessage()
        .authenticateAs('abc123', '123456')
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    */
  }

  // connection succeeded
  void onConnected() {
    print('Connected');
  }

  // unconnected
  void onDisconnected() {
    print('Disconnected');
  }

  // subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

  // subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

  // unsubscribe succeeded
  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

  // PING response received
  void pong() {
    print('Ping response client callback invoked');
  }
}
