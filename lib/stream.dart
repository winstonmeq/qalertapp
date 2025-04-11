import 'package:flutter/material.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


class MyStreamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeStreamScreen(),
    );
  }
}

class ChangeStreamScreen extends StatefulWidget {
  @override
  _ChangeStreamScreenState createState() => _ChangeStreamScreenState();
}

class _ChangeStreamScreenState extends State<ChangeStreamScreen> {

  final ChangeStreamService _streamService = ChangeStreamService();
  String _latestData = 'Waiting for updates...';

  @override
  void initState() {
    super.initState();
    // Start listening to the stream
    _streamService.startListening((data) {
      setState(() {
        _latestData = data; // Update UI with new data
      });
    });
  }

  @override
  void dispose() {
    _streamService.stopListening(); // Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MongoDB Change Stream'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_latestData),
        ),
      ),
    );
  }
}



class ChangeStreamService {

  final String backendUrl = 'http://192.168.1.6:3000/api/stream';

  StreamSubscription? _subscription;

  // Function to start listening to the change stream
  void startListening(void Function(String) onData) async {

    final request = http.Request('GET', Uri.parse(backendUrl));

    request.headers['Accept'] = 'text/event-stream'; // For SSE

    final response = await request.send();

    // Check if the connection is successful
    if (response.statusCode == 200) {
      // Listen to the stream
      _subscription = response.stream.transform(utf8.decoder).listen((data) {
        // Process the incoming data
        onData(data);
      }, onError: (error) {
        print('Error: $error');
      }, onDone: () {
        print('Stream closed');
      });
    } else {
      print('Failed to connect: ${response.statusCode}');
    }
  }

  // Function to stop listening
  void stopListening() {
    _subscription?.cancel();
  }
}