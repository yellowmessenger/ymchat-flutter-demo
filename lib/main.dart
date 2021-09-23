import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ymchat_flutter/ymchat_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initilizeChatbot();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('YmChat Demo'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            YmChat.startChatbot();
          },
          child: const Icon(Icons.message),
        ),
      ),
    );
  }

  void initilizeChatbot() {
    YmChat.setBotId("x1597301712805");
    YmChat.setPayload({"integration": "Flutter"});
    YmChat.showCloseButton(true);
    YmChat.setEnableHistory(true);

    EventChannel _ymEventChannel = const EventChannel("YMChatEvent");
    _ymEventChannel.receiveBroadcastStream().listen((event) {
      Map ymEvent = event;
      log("${ymEvent['code']} : ${ymEvent['data']}");
    });

    EventChannel _ymCloseEventChannel = const EventChannel("YMBotCloseEvent");
    _ymCloseEventChannel.receiveBroadcastStream().listen((event) {
      bool ymCloseEvent = event;
      log(event.toString());
    });
  }
}
