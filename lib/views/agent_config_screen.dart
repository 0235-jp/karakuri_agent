import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/agent_config.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/providers/viewmodels_provider.dart';
import 'package:karakuri_agent/viewmodels/agent_config_screen_viewmode.dart';
import 'package:karakuri_agent/i18n/strings.g.dart';

class AgentConfigScreen extends HookConsumerWidget {
  final AgentConfig? initialConfig;

  const AgentConfigScreen({super.key, this.initialConfig});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel =
        ref.watch(agentConfigScreenViewmodelProvider(initialConfig));
    final initialized = ref.watch(viewModel.initializedProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(initialConfig == null
            ? t.home.agent.agentAdd
            : t.home.agent.agentEdit),
      ),
      body: !initialized
          ? const Center(child: CircularProgressIndicator())
          : _AgentConfigContent(viewModel: viewModel),
    );
  }
}

class _AgentConfigContent extends HookConsumerWidget {
  final AgentConfigScreenViewmode viewModel;

  const _AgentConfigContent({required this.viewModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = ref.watch(viewModel.nameControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
                // TODO
                labelText: t.settings.serviceSettings.serviceConfig.name),
          ),
          _TextConfigSection(viewmodel: viewModel),
          _SpeechToTextConfigSection(viewmodel: viewModel),
          _TextToSpeechConfigSection(viewmodel: viewModel),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _saveConfig(context, ref, viewModel),
            child: Text(t.settings.serviceSettings.serviceConfig.save),
          ),
        ],
      ),
    );
  }

  void _saveConfig(
    BuildContext context,
    WidgetRef ref,
    AgentConfigScreenViewmode viewModel,
  ) {
    // final error = viewModel.validationCheck();
    // if (error != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(error),
    //   ));
    //   return;
    // }
    Navigator.of(context).pop(viewModel.createAgentConfig());
  }
}

class _TextConfigSection extends HookConsumerWidget {
  final AgentConfigScreenViewmode viewmodel;

  const _TextConfigSection({
    required this.viewmodel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(viewmodel.textServiceConfigsProvider);
    final selectService = ref.watch(viewmodel.selectTextServiceProvider);
    final models = ref.watch(viewmodel.textModelsProvider);
    final selectModel = ref.watch(viewmodel.selectTextModelProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ServiceDropdownSection(
          serviceConfig: selectService,
          servicesConfigs: services,
          onChanged: (value) {
            viewmodel.setTextServiceConfig(value);
          },
        ),
        models.isNotEmpty
            ? _ModelDropdownSection(
                model: selectModel,
                models: models,
                onChanged: (value) {
                  viewmodel.setTextModel(value);
                },
              )
            : const SizedBox(),
      ],
    );
  }
}

class _SpeechToTextConfigSection extends HookConsumerWidget {
  final AgentConfigScreenViewmode viewmodel;

  const _SpeechToTextConfigSection({
    required this.viewmodel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(viewmodel.speechToTextServiceConfigsProvider);
    final selectService =
        ref.watch(viewmodel.selectSpeechToTextServiceProvider);
    final models = ref.watch(viewmodel.speechToTextModelsProvider);
    final selectModel = ref.watch(viewmodel.selectSpeechToTextModelProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ServiceDropdownSection(
          serviceConfig: selectService,
          servicesConfigs: services,
          onChanged: (value) {
            viewmodel.setSpeechToTextServiceConfig(value);
          },
        ),
        models.isNotEmpty
            ? _ModelDropdownSection(
                model: selectModel,
                models: models,
                onChanged: (value) {
                  viewmodel.setSpeechToText(value);
                },
              )
            : const SizedBox(),
      ],
    );
  }
}

class _TextToSpeechConfigSection extends HookConsumerWidget {
  final AgentConfigScreenViewmode viewmodel;

  const _TextToSpeechConfigSection({
    required this.viewmodel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(viewmodel.textToSpeechServiceConfigsProvider);
    final selectService =
        ref.watch(viewmodel.selectTextToSpeechServiceProvider);
    final models = ref.watch(viewmodel.textToSpeechVoicesProvider);
    final selectModel = ref.watch(viewmodel.selectTextToSpeechVoiceProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ServiceDropdownSection(
          serviceConfig: selectService,
          servicesConfigs: services,
          onChanged: (value) {
            viewmodel.setTextToSpeechServiceConfig(value);
          },
        ),
        models.isNotEmpty
            ? _ModelDropdownSection(
                model: selectModel,
                models: models,
                onChanged: (value) {
                  viewmodel.setTextToSpeech(value);
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

class _ModelDropdownSection extends HookConsumerWidget {
  final (String, String)? model;
  final List<(String, String)> models;
  final Function((String, String)?) onChanged;

  const _ModelDropdownSection({
    required this.model,
    required this.models,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<(String, String)>(
      value: model,
      onChanged: ((String, String)? newValue) => onChanged(newValue),
      items: models
          .map<DropdownMenuItem<(String, String)>>(((String, String) item) {
        return DropdownMenuItem<(String, String)>(
          value: item,
          child: Text(item.$2),
        );
      }).toList(),
    );
  }
}
