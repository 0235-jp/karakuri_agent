import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/providers/viewmodel.dart';
import 'package:karakuri_agent/viewmodels/talk_screen_viewmodel.dart';
import 'package:karakuri_agent/i18n/strings.g.dart';

class TalkScreen extends HookConsumerWidget {
  final String _serviceId;
  final String _modelId;

  const TalkScreen(this._serviceId, this._modelId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel =
        ref.watch(talkScreenViewmodelProvider((_serviceId, _modelId)));
    final serviceConfig = ref.watch(viewModel.serviceConfigProvider);
    if (serviceConfig == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return _TalkContent(
        viewModel: viewModel,
        config: serviceConfig,
      );
    }
  }
}

class _TalkContent extends HookConsumerWidget {
  final TalkScreenViewmodel viewModel;
  final ServiceConfig config;

  const _TalkContent({required this.viewModel, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isListning = ref.watch(viewModel.isListningProvider);
    final text = ref.watch(viewModel.textProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.serviceSettings.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(text ?? 'no text'),
            ElevatedButton(
              onPressed: () {
                if (isListning) {
                  print('pause');
                  viewModel.pause();
                } else {
                  print('start');
                  viewModel.start();
                }
              },
              child: Text(isListning ? 'pause' : 'start'),
            ),
          ],
        ),
      ),
    );
  }
}
