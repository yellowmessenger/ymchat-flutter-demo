import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ymchat_flutter/ymchat_flutter.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String deviceToken = "";
  String apiKey = "";
  String botId = "x1645602443989";
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
            child: Column(
          children: [
            TextButton(
              onPressed: () {
                YmChat.unLinkDeviceToken(apiKey, () {
                  log("Unlink Device Token: success");
                }, (p0) {
                  log('Unlink Device token failed: $p0');
                });
              },
              child: const Text("Unlink device token"),
            ),
            TextButton(
              onPressed: () {
                log("1");
                YmChat.setBotId(botId);
                log("2");
                YmChat.setAuthenticationToken("authToken");
                log("3");
                YmChat.setDeviceToken("deviceToken");
                log("4");
                // unlink device token
                YmChat.registerDevice(apiKey, (p0) {
                  log("register device: success");
                }, (failureMessage) {
                  log("register device failed: $failureMessage");
                });
              },
              child: const Text("Register Device"),
            ),
            TextButton(
              onPressed: () {
                YmChat.setBotId(botId);
                YmChat.setAuthenticationToken("authToken");

                YmChat.getUnreadMessages((count) {
                  log("Unread Message Count: $count");
                }, (failureMessage) {
                  log(failureMessage);
                });
              },
              child: const Text("Unread Message Count"),
            ),
          ],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Internet connectivity must be validated before launching bot
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

  void showAlertDialog(String description) {
    // set up the button
    Widget okButton = TextButton(
      onPressed: () => Navigator.pop(context, 'OK'),
      child: const Text('OK'),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Event"),
      content: Text(description),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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

    YmChat.useLiteVersion(false);

    YmChat.setThemeBotName('Demo Bot Name');
    YmChat.setThemeBotDescription('Demo Bot Description');
    YmChat.setThemePrimaryColor('#ff0000');
    YmChat.setThemeSecondaryColor('#00ff00');
    YmChat.setThemeBotBubbleBackgroundColor('#0000ff');
    YmChat.setThemeBotIcon(
        'https://cdn.yellowmessenger.com/XJFcMhLpN6L91684914460598.png');
    YmChat.setThemeBotClickIcon(
        'https://cdn.yellowmessenger.com/XJFcMhLpN6L91684914460598.png');

    // Listening to bot events
    EventChannel _ymEventChannel = const EventChannel("YMChatEvent");
    _ymEventChannel.receiveBroadcastStream().listen((event) async {
      Map ymEvent = event;
      log("Flutter App: ${ymEvent['code']} : ${ymEvent['data']}");
      // showAlertDialog("${ymEvent['code']} : ${ymEvent['data']}");
      // YmChat.closeBot();
    });

    // Listening to close bot events
    EventChannel _ymCloseEventChannel = const EventChannel("YMBotCloseEvent");
    _ymCloseEventChannel.receiveBroadcastStream().listen((event) {
      // bool ymCloseEvent = event;
      log(event.toString());
      showAlertDialog("Bot Closed");
    });
  }
}
