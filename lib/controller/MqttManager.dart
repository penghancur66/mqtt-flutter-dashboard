import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_iot/controller/MqttProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MQTTManager {
  final MqttAppState _appState;
  MqttServerClient _client;
  final String _host;
  final String _topicMain;

  var topicSuhu;
  var topicBpm;
  var topicOksigen;
  var topicTekananSistole;
  var topicTekananDiastole;

  MQTTManager(
      {@required String host,
      @required String topicMain,
      @required MqttAppState appState})
      : _host = host,
        _topicMain = topicMain,
        _appState = appState;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, 'mqtt-iot');
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.onDisconnected = onDisconnected;
    _client.secure = false;
    _client.logging(on: true);

    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;

    final MqttConnectMessage connectMessage = MqttConnectMessage()
        .withClientIdentifier('mqtt-iot')
        .withWillTopic('willTopic')
        .withWillMessage('Message Mqtt Iot')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('Mosquito client connecting...');
    _client.connectionMessage = connectMessage;
  }

  //connect to host

  void connect() async {
    assert(_client != null);
    try {
      print('Mosquito start client connecting...');
      _appState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client.connect();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      topicSuhu = preferences.getString('topicSuhu');
      topicBpm = preferences.getString('topicBpm');
      topicOksigen = preferences.getString('topicOksigen');
      topicTekananSistole = preferences.getString('topicTekananSistole');
      topicTekananDiastole = preferences.getString('topicTekananDiastole');
    } on Exception catch (e) {
      print('Client error, except - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Mqtt Disconnect');
    _client.disconnect();
  }

  //mqtt-manager.dart
  void publish(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
    print('message');
  }

  void onSubscribed(String topic) {
    print('Subscribe confirmed from topic $topic');
  }

  void onDisconnected() {
    print('onDisconnect client callback - Client disconnection');

    if (_client.connectionStatus.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('OnDisconnected callback is solicited, this is correct');
    }
    _appState.setAppConnectionState(MQTTAppConnectionState.disconnect);
  }

  void onConnected() {
    _appState.setAppConnectionState(MQTTAppConnectionState.connected);
    print('Mosquito client connected...');
    _client.subscribe(_topicMain, MqttQos.atLeastOnce);
    _client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;

      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      DateTime now = DateTime.now();
      String timestamp = DateFormat('yyyy-MM-dd - kk:mm:ss').format(now);

      if (c[0].topic == topicSuhu) {
        _appState.setReceivedTemp(pt);
        _appState.setAppMqttSubscribe(MqttSubscribe.yes);
      } else if (c[0].topic == topicBpm) {
        _appState.setReceivedBpm(pt);
        _appState.setAppMqttSubscribe(MqttSubscribe.yes);
      } else if (c[0].topic == topicOksigen) {
        _appState.setReceivedOksigen(pt);
        _appState.setAppMqttSubscribe(MqttSubscribe.yes);
      } else if (c[0].topic == topicTekananSistole) {
        _appState.setReceivedTekananSistole(pt);
        _appState.setAppMqttSubscribe(MqttSubscribe.yes);
      } else if (c[0].topic == topicTekananDiastole) {
        _appState.setReceivedTekananDiastole(pt);
        _appState.setAppMqttSubscribe(MqttSubscribe.yes);
      }
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}
