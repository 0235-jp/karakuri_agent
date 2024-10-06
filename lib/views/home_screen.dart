import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/agent_config.dart';
import 'package:karakuri_agent/providers/viewmodels_provider.dart';
import 'package:karakuri_agent/viewmodels/home_screen_viewmodel.dart';
import 'package:karakuri_agent/views/agent_config_screen.dart';
import 'package:karakuri_agent/views/custom_view/link_text.dart';
import 'package:karakuri_agent/i18n/strings.g.dart';
import 'package:karakuri_agent/views/service_settings_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeScreenViewmodelProvider);
    final initialized = ref.watch(viewModel.initializedProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.home.title),
      ),
      body: !initialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  _AgentContent(viewModel: viewModel)
                ],
              ),
            ),
    );
  }
}

class _AgentContent extends HookConsumerWidget {
  final HomeScreenViewmodel viewModel;

  const _AgentContent({required this.viewModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(viewModel.agentConfigsProvider);
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: configs!.length,
            itemBuilder: (context, index) {
              final config = configs[index];
              return _AgentCard(
                config: config,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton(
              child: Text(t.settings.serviceSettings.addService),
              onPressed: () async {
                final agentConfig = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const AgentConfigScreen(),
                  ),
                ) as AgentConfig?;
                if (agentConfig != null) {
                  viewModel.saveAgentConfig(agentConfig);
                }
              },
            ),
          ),
        ],
      );
    }
}

class _AgentCard extends HookConsumerWidget {
  final AgentConfig config;

  const _AgentCard({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(homeScreenViewmodelProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.home.agent.name(name: config.name),
            ),
            Text(
              t.home.agent.textModel(
                  name:
                      '${config.textServiceConfig.name}:${config.textModelName}'),
            ),
            Text(
              t.home.agent.speechToTextModel(
                  name:
                      '${config.speechToTextServiceConfig.name}:${config.speechToTextModelName}'),
            ),
            Text(
              t.home.agent.textToSpeechModel(
                  name:
                      '${config.textToSpeechServiceConfig.name}:${config.textToSpeechModelName}'),
            ),
            TextButton(
              child: Text(t.settings.serviceSettings.editService),
              onPressed: () async {
                final agentConfig = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        AgentConfigScreen(initialConfig: config),
                  ),
                ) as AgentConfig?;
                if (agentConfig != null) {
                  viewModel.saveAgentConfig(agentConfig);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
