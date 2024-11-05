import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/agent_config.dart';
import 'package:karakuri_agent/models/key_value_pair.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/i18n/strings.g.dart';
import 'package:karakuri_agent/providers/view_model_providers.dart';
import 'package:karakuri_agent/view_models/agent_config_screen_view_model.dart';

class AgentConfigScreen extends HookConsumerWidget {
  final AgentConfig? initialConfig;
  const AgentConfigScreen({super.key, this.initialConfig});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AgentConfigScreenViewModel>(
      agentConfigScreenViewModelProvider(initialConfig),
      (_, __) {},
    );
    final initialized = ref.watch(
        agentConfigScreenViewModelProvider(initialConfig)
            .select((it) => it.initialized));
    return Scaffold(
      appBar: AppBar(
        title: Text(initialConfig == null
            ? t.home.agent.agentConfig.agentAdd
            : t.home.agent.agentConfig.agentEdit),
      ),
      body: !initialized
          ? const Center(child: CircularProgressIndicator())
          : _AgentConfigContent(initialConfig: initialConfig),
    );
  }
}

class _AgentConfigContent extends HookConsumerWidget {
  final AgentConfig? initialConfig;
  const _AgentConfigContent({required this.initialConfig});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = ref.read(
        agentConfigScreenViewModelProvider(initialConfig)
            .select((it) => it.nameController));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration:
                InputDecoration(labelText: t.home.agent.agentConfig.name),
          ),
          _ImageKeySection(initialConfig: initialConfig),
          _TextConfigSection(initialConfig: initialConfig),
          _SpeechToTextConfigSection(initialConfig: initialConfig),
          _TextToSpeechConfigSection(initialConfig: initialConfig),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _saveConfig(context, ref, initialConfig),
            child: Text(t.home.agent.agentConfig.save),
          ),
        ],
      ),
    );
  }

  void _saveConfig(
    BuildContext context,
    WidgetRef ref,
    AgentConfig? initialConfig,
  ) {
    final viewModel =
        ref.read(agentConfigScreenViewModelProvider(initialConfig));
    final error = viewModel.validationCheck();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
      ));
      return;
    }
    Navigator.of(context).pop(viewModel.createAgentConfig());
  }
}

class _ImageKeySection extends HookConsumerWidget {
  final AgentConfig? initialConfig;
  const _ImageKeySection({
    required this.initialConfig,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewmodel =
        ref.read(agentConfigScreenViewModelProvider(initialConfig));
    final (imageKeys, selectImageKey) = ref.watch(
      agentConfigScreenViewModelProvider(initialConfig).select(
        (it) => (
          it.imageKeys,
          it.selectImageKey,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO
        Text(t.home.agent.agentConfig.textService),
        DropdownButton<String>(
          value: selectImageKey,
          onChanged: (String? newValue) => viewmodel.updateImageKey(newValue),
          items: imageKeys.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TextConfigSection extends HookConsumerWidget {
  final AgentConfig? initialConfig;
  const _TextConfigSection({
    required this.initialConfig,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewmodel =
        ref.read(agentConfigScreenViewModelProvider(initialConfig));
    final (services, selectService, models, selectModel) = ref.watch(
      agentConfigScreenViewModelProvider(initialConfig).select(
        (it) => (
          it.textServiceConfigs,
          it.selectTextService,
          it.textModels,
          it.selectTextModel
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.home.agent.agentConfig.textService),
        _ServiceDropdownSection(
          serviceConfig: selectService,
          servicesConfigs: services,
          onChanged: (value) {
            viewmodel.updateTextServiceConfig(value);
          },
        ),
        Text(t.home.agent.agentConfig.textModel),
        models.isNotEmpty
            ? _OptionDropdownSection(
                model: selectModel,
                models: models,
                onChanged: (value) {
                  viewmodel.updateTextModel(value);
                },
              )
            : const SizedBox(),
      ],
    );
  }
}

class _SpeechToTextConfigSection extends HookConsumerWidget {
  final AgentConfig? initialConfig;
  const _SpeechToTextConfigSection({
    required this.initialConfig,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewmodel =
        ref.read(agentConfigScreenViewModelProvider(initialConfig));
    final (services, selectService, models, selectModel) = ref.watch(
      agentConfigScreenViewModelProvider(initialConfig).select(
        (it) => (
          it.speechToTextServiceConfigs,
          it.selectSpeechToTextService,
          it.speechToTextModels,
          it.selectSpeechToTextModel
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.home.agent.agentConfig.speechToTextService),
        _ServiceDropdownSection(
          serviceConfig: selectService,
          servicesConfigs: services,
          onChanged: (value) {
            viewmodel.updateSpeechToTextServiceConfig(value);
          },
        ),
        Text(t.home.agent.agentConfig.speechToTextModel),
        models.isNotEmpty
            ? _OptionDropdownSection(
                model: selectModel,
                models: models,
                onChanged: (value) {
                  viewmodel.updateSpeechToTextModel(value);
                },
              )
            : const SizedBox(),
      ],
    );
  }
}

class _TextToSpeechConfigSection extends HookConsumerWidget {
  final AgentConfig? initialConfig;
  const _TextToSpeechConfigSection({
    required this.initialConfig,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewmodel =
        ref.read(agentConfigScreenViewModelProvider(initialConfig));
    final (services, selectService, models, selectModel, voices, selectVoice) =
        ref.watch(
      agentConfigScreenViewModelProvider(initialConfig).select(
        (it) => (
          it.textToSpeechServiceConfigs,
          it.selectTextToSpeechService,
          it.textToSpeechModels,
          it.selectTextToSpeechModel,
          it.textToSpeechVoices,
          it.selectTextToSpeechVoice
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.home.agent.agentConfig.textToSpeechService),
        _ServiceDropdownSection(
          serviceConfig: selectService,
          servicesConfigs: services,
          onChanged: (value) {
            viewmodel.updateTextToSpeechServiceConfig(value);
          },
        ),
        Text(t.home.agent.agentConfig.textToSpeechModel),
        models.isNotEmpty
            ? _OptionDropdownSection(
                model: selectModel,
                models: models,
                onChanged: (value) {
                  viewmodel.updateTextToSpeechModel(value);
                },
              )
            : const SizedBox(),
        Text(t.home.agent.agentConfig.textToSpeechVoice),
        voices.isNotEmpty
            ? _OptionDropdownSection(
                model: selectVoice,
                models: voices,
                onChanged: (value) {
                  viewmodel.updateTextToSpeechVoice(value);
                },
              )
            : const SizedBox(),
      ],
    );
  }
}

class _ServiceDropdownSection extends HookConsumerWidget {
  final ServiceConfig? serviceConfig;
  final List<ServiceConfig> servicesConfigs;
  final Function(ServiceConfig?) onChanged;
  const _ServiceDropdownSection({
    required this.serviceConfig,
    required this.servicesConfigs,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<ServiceConfig>(
      value: serviceConfig,
      onChanged: (ServiceConfig? newValue) => onChanged(newValue),
      items: servicesConfigs
          .map<DropdownMenuItem<ServiceConfig>>((ServiceConfig item) {
        return DropdownMenuItem<ServiceConfig>(
          value: item,
          child: Text(item.name),
        );
      }).toList(),
    );
  }
}

class _OptionDropdownSection extends HookConsumerWidget {
  final KeyValuePair? model;
  final List<KeyValuePair> models;
  final Function(KeyValuePair?) onChanged;
  const _OptionDropdownSection({
    required this.model,
    required this.models,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<KeyValuePair>(
      value: model,
      onChanged: (KeyValuePair? newValue) => onChanged(newValue),
      items: models.map<DropdownMenuItem<KeyValuePair>>((KeyValuePair item) {
        return DropdownMenuItem<KeyValuePair>(
          value: item,
          child: Text(item.value),
        );
      }).toList(),
    );
  }
}
