import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  final messages = <String>[];
  final messageController = ScrollController();


  @override
  void initState() {
    connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('消息推送测试'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  controller: messageController,
                  children: _buildMessageList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('Clear'),
                  onPressed: () {
                    setState(() {
                      messages.clear();
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void connect() async {
    final broker = 'graduation-project.mqtt.iot.bj.baidubce.com';
    final port = 1883;
    final username = 'graduation-project/xiaomi';
    final password = 'uQcpeTOlJOAFK3gE';
    final topic = 'message';
    final mqtt.MqttClient client = mqtt.MqttClient.withPort(broker, '', port);
    final mqtt.MqttConnectMessage message = mqtt.MqttConnectMessage()
        .withClientIdentifier("xiaomi")
        .startClean()
        .keepAliveFor(20);
    client.connectionMessage = message;
    try {
      await client.connect(username, password);
    } on Exception catch (e) {
      print('exception $e');
    }

    assert(client.connectionStatus.state == mqtt.MqttConnectionState.connected);
    client.subscribe(topic, mqtt.MqttQos.atLeastOnce);
    client.updates.listen((dynamic c) {
      final mqtt.MqttPublishMessage msg = c[0].payload;
      String pt =
          mqtt.MqttPublishPayload.bytesToStringAsString(msg.payload.message);
      setState(() {
        messages.add(pt);
        try {
          messageController.animateTo(
            0.0,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        } catch (_) {
          // ScrollController not attached to any scroll views.
        }
      });
    });
  }

  List<Widget> _buildMessageList() {
    return messages
        .map((String message) => Card(
              color: Colors.white70,
              child: ListTile(
                subtitle: Text(message),
                dense: true,
              ),
            ))
        .toList()
        .reversed
        .toList();
  }
}
