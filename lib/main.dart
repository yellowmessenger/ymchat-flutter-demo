import 'dart:developer';
import 'dart:io';

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
  final _inputKey = GlobalKey<FormState>();
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    initializeChatbot();
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
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
          onPressed: () async {
            if (await hasNetwork()) {
              YmChat.startChatbot();
            } else {
              const snackBar = SnackBar(
                content:
                    Text("Network issue, Please check your network connection"),
              );
              _messangerKey.currentState?.showSnackBar(snackBar);
            }
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
