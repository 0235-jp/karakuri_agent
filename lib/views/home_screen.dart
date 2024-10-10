import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/views/custom_view/link_text.dart';
import 'package:karakuri_agent/i18n/strings.g.dart';
import 'package:karakuri_agent/views/service_settings_screen.dart';
import 'package:karakuri_agent/views/talk_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.home.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LinkText(
              text: t.settings.serviceSettings.title,
              onTap: () async {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const ServiceSettingsScreen(),
                  ),
                );
              },
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      // TODO モデルの取得
                      builder: (context) => const TalkScreen("", "whisper-1"),
                    ),
                  );
                },
                child: Text('トーク画面')),
          ],
        ),
      ),
    );
  }
}
