import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/agent_config.dart';
import 'package:karakuri_agent/providers/viewmodel_providers.dart';
import 'package:karakuri_agent/viewmodels/home_screen_viewmodel.dart';
import 'package:karakuri_agent/views/agent_config_screen.dart';
import 'package:karakuri_agent/views/custom_view/link_text.dart';
import 'package:karakuri_agent/i18n/strings.g.dart';
import 'package:karakuri_agent/views/service_settings_screen.dart';
import 'package:karakuri_agent/views/talk_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<HomeScreenViewModel>(
      homeScreenViewModelProvider,
      (_, __) {},
    );
    final viewModel = ref.read(homeScreenViewModelProvider);
    final initialized =
        ref.watch(homeScreenViewModelProvider.select((it) => it.initialized));
    return Scaffold(
      appBar: AppBar(
        title: Text(t.home.title),
      ),
      body: !initialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
  final HomeScreenViewModel viewModel;

  const _AgentContent({required this.viewModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs =
        ref.watch(homeScreenViewModelProvider.select((it) => it.agentConfigs));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...configs.map((config) => _AgentCard(config: config)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton(
            child: Text(t.home.agent.addAgent),
            onPressed: () async {
              final agentConfig = await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AgentConfigScreen(),
                ),
              ) as AgentConfig?;
              if (agentConfig != null) {
                viewModel.addAgentConfig(agentConfig);
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
    final viewModel = ref.read(homeScreenViewModelProvider);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      '${config.textServiceConfig.name}:${config.textModel.value}'),
            ),
            Text(
              t.home.agent.speechToTextModel(
                  name:
                      '${config.speechToTextServiceConfig.name}:${config.speechToTextModel.value}'),
            ),
            Text(
              t.home.agent.textToSpeechModel(
                  name:
                      '${config.textToSpeechServiceConfig.name}:${config.textToSpeechModel.value}'),
            ),
            Text(
              t.home.agent.textToSpeechVoice(
                  name:
                      '${config.textToSpeechServiceConfig.name}:${config.textToSpeechVoice.value}'),
            ),
            Row(
              children: [
                TextButton(
                  child: Text(t.home.agent.startTalk),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => TalkScreen(config),
                      ),
                    );
                  },
                ),
                TextButton(
                  child: Text(t.home.agent.editAgent),
                  onPressed: () async {
                    final agentConfig = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            AgentConfigScreen(initialConfig: config),
                      ),
                    ) as AgentConfig?;
                    if (agentConfig != null) {
                      viewModel.updateAgentConfig(agentConfig);
                    }
                  },
                ),
                TextButton(
                  child: Text(t.home.agent.deleteAgent),
                  onPressed: () async {
                    if (config.id != null) {
                      viewModel.deleteAgentConfig(config.id!);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
