import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
  requestPermission();
}

void requestPermission() async {
  if (Platform.isAndroid) {
    await Permission.manageExternalStorage.request();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UDP Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RawDatagramSocket? _socket;
  String _receivedMessage = '';

  @override
  void initState() {
    super.initState();
    _bindSocket();
  }

  void _bindSocket() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 12345);
    _socket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = _socket!.receive();
        if (dg != null) {
          setState(() {
            _receivedMessage = utf8.decode(dg.data);
          });
        }
      }
    });
  }

  void _send(String message, InternetAddress ipAddress, int port) {
    List<int> data = utf8.encode(message);
    _socket!.send(data, ipAddress, port);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter UDP Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Received Message:',
            ),
            Text(
              '$_receivedMessage',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _send('Hello, UDP!', InternetAddress.loopbackIPv4, 12345),
        tooltip: 'Send',
        child: Icon(Icons.send),
      ),
    );
  }
}
