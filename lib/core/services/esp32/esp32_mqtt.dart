// ignore_for_file: invalid_use_of_protected_member

part of '../esp32_service.dart';

extension Esp32Mqtt on Esp32Service {
  Future<void> _connectMqtt() async {
    _disconnectMqtt();
    _isConnecting = true;
    debugPrint('Connecting to MQTT broker at: $brokerUrl');
    
    final clientId = 'flutter_client_${const Uuid().v4()}';
    _client = MqttServerClient(brokerUrl, clientId);
    _client!.port = 1883;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean(); // Non persistent session for mobile app
    
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      debugPrint('MQTT client exception: $e');
      _isConnecting = false;
      _disconnectMqtt();
      _reconnectAfterDelay();
    }
  }

  void _onConnected() {
    _isConnecting = false;
    debugPrint('MQTT Connected');
    ref.read(isConnectedProvider.notifier).set(true);
    
    // Subscribe to topics
    _client!.subscribe(Esp32Service.topicState, MqttQos.atLeastOnce);
    _client!.subscribe(Esp32Service.topicSensor, MqttQos.atLeastOnce);
    _client!.subscribe(Esp32Service.topicEvent, MqttQos.atLeastOnce);
    _client!.subscribe(Esp32Service.topicStatus, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _handleMessage(c[0].topic, payload);
    });

    // Request initial state
    sendRawMessage({'action': 'get_state'});
  }

  void _onDisconnected() {
    _isConnecting = false;
    debugPrint('MQTT Disconnected');
    ref.read(isConnectedProvider.notifier).set(false);
    _reconnectAfterDelay();
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT Subscribed to $topic');
  }

  void _disconnectMqtt() {
    _isConnecting = false;
    if (_client != null && _client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.disconnect();
    }
    _client = null;
  }

  void _reconnectAfterDelay() {
    if (_reconnecting) return;
    _reconnecting = true;
    Future.delayed(const Duration(seconds: 5), () {
      _reconnecting = false;
      _connectMqtt();
    });
  }

  void _reconnect() {
    _disconnectMqtt();
    _connectMqtt();
  }

  void _handleMessage(String topic, String message) {
    debugPrint('<-- MQTT MESSAGE [$topic]: $message');
    
    if (topic == Esp32Service.topicStatus) {
      // Device online/offline LWT handling
      if (message == 'online') {
        // You could use this to update hubReachability specifically if wanted
      }
      return;
    }

    try {
      final data = jsonDecode(message) as Map<String, dynamic>;

      if (topic == Esp32Service.topicState) {
        if (_stateCompleter != null && !_stateCompleter!.isCompleted) {
          _stateCompleter!.complete(data);
        }
        _syncStateWithControllers(data);
      } else if (topic == Esp32Service.topicSensor) {
        _syncSensorsWithControllers(data);
      } else if (topic == Esp32Service.topicEvent) {
        final String? event = data['event'];
        if (event == 'relay_update') {
          _syncRelayWithControllers(data);
        } else if (event == 'pwm_update') {
          _syncPwmWithControllers(data);
        } else if (event == 'ac_update') {
          _syncAcWithControllers(data);
        } else if (event == 'ir_learn_status') {
          _handleIrLearnStatus(data);
        }
      }
    } catch (e) {
      debugPrint('Error decoding MQTT message: $e');
    }
  }

  /// Send raw map over MQTT
  bool sendRawMessage(Map<String, dynamic> jsonMap) {
    if (_client == null || !ref.read(isConnectedProvider)) {
      debugPrint('Cannot send MQTT message: not connected');
      return false;
    }
    try {
      debugPrint('--> MQTT SEND [${Esp32Service.topicCmd}]: $jsonMap');
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(jsonMap));
      _client!.publishMessage(Esp32Service.topicCmd, MqttQos.atLeastOnce, builder.payload!);
      return true;
    } catch (e) {
      debugPrint('Error sending MQTT message: $e');
      return false;
    }
  }
}
