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
  String deviceToken = "";
  String apiKey =
      "a6aee4bc2885b10c2c1b02b96080263057438d2673a5512c6b64da2a3f818ee7";
  String botId = "x1608615889375";

  @override
  void initState() {
    super.initState();
    initializeChatbot();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('YmChat Demo'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              // unlink device token
              YmChat.unLinkDeviceToken(botId, apiKey, deviceToken, () {
                log("Device token unlinked successfully");
              }, (failureMessage) {
                log(failureMessage);
              });
            },
            child: const Text("UnLink device token"),
          ),
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

  void initializeChatbot() {
    // Initializing chatbot id to work with in the SDK
    YmChat.setBotId(botId);

    // Adding payload to communicate with chatbot
    YmChat.setPayload({"integration": "Flutter"});

    // Enabling UI close button
    YmChat.showCloseButton(true);

    // Enabling voice input
    YmChat.setEnableSpeech(true);
    // using v2 widget
    YmChat.setVersion(2);

    // Listening to bot events
    EventChannel _ymEventChannel = const EventChannel("YMChatEvent");
    _ymEventChannel.receiveBroadcastStream().listen((event) {
      Map ymEvent = event;
      log("${ymEvent['code']} : ${ymEvent['data']}");
    });

    // Listening to close bot events
    EventChannel _ymCloseEventChannel = const EventChannel("YMBotCloseEvent");
    _ymCloseEventChannel.receiveBroadcastStream().listen((event) {
      bool ymCloseEvent = event;
      log(event.toString());
    });
  }
}
