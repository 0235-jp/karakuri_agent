import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/agent_config.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/repositories/config_storage_repository.dart';

class AgentConfigScreenViewmode {
  final AutoDisposeProviderRef _ref;
  final ConfigStorageRepository _configStorage;
  final AgentConfig? _agentConfig;
  final AutoDisposeStateProvider<bool> initializedProvider =
      StateProvider.autoDispose<bool>((ref) => false);
  late AutoDisposeStateProvider<TextEditingController> nameControllerProvider;

  late AutoDisposeStateProvider<ServiceConfig?> selectTextServiceProvider;
  late AutoDisposeStateProvider<(String, String)?> selectTextModelProvider;

  late AutoDisposeStateProvider<ServiceConfig?>
      selectSpeechToTextServiceProvider;
  late AutoDisposeStateProvider<(String, String)?>
      selectSpeechToTextModelProvider;

  late AutoDisposeStateProvider<ServiceConfig?>
      selectTextToSpeechServiceProvider;
  late AutoDisposeStateProvider<(String, String)?>
      selectTextToSpeechVoiceProvider;

  late AutoDisposeStateProvider<List<ServiceConfig>> textServiceConfigsProvider;
  late AutoDisposeStateProvider<List<(String, String)>> textModelsProvider;

  late AutoDisposeStateProvider<List<ServiceConfig>>
      speechToTextServiceConfigsProvider;
  late AutoDisposeStateProvider<List<(String, String)>>
      speechToTextModelsProvider;

  late AutoDisposeStateProvider<List<ServiceConfig>>
      textToSpeechServiceConfigsProvider;
  late AutoDisposeStateProvider<List<(String, String)>>
      textToSpeechVoicesProvider;

  AgentConfigScreenViewmode(this._ref, this._configStorage,
      {AgentConfig? agentConfig})
      : _agentConfig = agentConfig {
    _ref.onDispose(() {});
  }

  Future<void> build() async {
    nameControllerProvider =
        StateProvider.autoDispose<TextEditingController>((ref) {
      final controller = TextEditingController(text: _agentConfig?.name ?? '');
      ref.onDispose(() {
        controller.dispose();
      });
      return controller;
    });

    _buildTextService();
    _buildSpeechToTextService();
    _buildTextToSpeechService();

    _ref.watch(initializedProvider.notifier).state = true;
  }

  Future<void> _buildTextService() async {
    selectTextServiceProvider = StateProvider.autoDispose<ServiceConfig?>(
        (ref) => _agentConfig?.textServiceConfig);
    selectTextModelProvider = StateProvider.autoDispose<(String, String)?>(
        (ref) => _agentConfig != null
            ? (_agentConfig.textModel, _agentConfig.textModelName)
            : null);

    final textServiceConfig = await _configStorage.loadTextServiceConfigs();
    textServiceConfigsProvider = StateProvider.autoDispose<List<ServiceConfig>>(
        (ref) => textServiceConfig);
    textModelsProvider =
        StateProvider.autoDispose<List<(String, String)>>((ref) {
      final selectTextService = _ref.read(selectTextServiceProvider);
      return selectTextService?.textConfig?.models ?? [];
    });
  }

  Future<void> _buildSpeechToTextService() async {
    selectSpeechToTextServiceProvider =
        StateProvider.autoDispose<ServiceConfig?>(
            (ref) => _agentConfig?.speechToTextServiceConfig);
    selectSpeechToTextModelProvider =
        StateProvider.autoDispose<(String, String)?>((ref) => _agentConfig !=
                null
            ? (_agentConfig.speechToTextModel, _agentConfig.speechToTextModel)
            : null);

    final speechToTextSericeConfig =
        await _configStorage.loadSpeechToTextServiceConfigs();
    speechToTextServiceConfigsProvider =
        StateProvider.autoDispose<List<ServiceConfig>>((ref) {
      return speechToTextSericeConfig;
    });
    speechToTextModelsProvider =
        StateProvider.autoDispose<List<(String, String)>>((ref) {
      final selectSpeechToTextService =
          _ref.read(selectSpeechToTextServiceProvider);
      return selectSpeechToTextService?.speechToTextConfig?.models ?? [];
    });
  }

  Future<void> _buildTextToSpeechService() async {
    selectTextToSpeechServiceProvider =
        StateProvider.autoDispose<ServiceConfig?>(
            (ref) => _agentConfig?.textToSpeechServiceConfig);
    selectTextToSpeechVoiceProvider =
        StateProvider.autoDispose<(String, String)?>((ref) => _agentConfig !=
                null
            ? (_agentConfig.textToSpeechModel, _agentConfig.textToSpeechModel)
            : null);

    final textToSpeechServiceConfig =
        await _configStorage.loadTextToSpeechServiceConfigs();
    textToSpeechServiceConfigsProvider =
        StateProvider.autoDispose<List<ServiceConfig>>((ref) {
      return textToSpeechServiceConfig;
    });
    textToSpeechVoicesProvider =
        StateProvider.autoDispose<List<(String, String)>>((ref) {
      final selectTextToSpeechService =
          _ref.read(selectTextToSpeechServiceProvider);
      return selectTextToSpeechService?.textToSpeechConfig?.voices ?? [];
    });
  }

  void setTextServiceConfig(ServiceConfig? config) {
    _ref.read(selectTextModelProvider.notifier).update((state) {
      if (_ref.read(selectTextServiceProvider) != config) {
        return null;
      } else {
        return state;
      }
    });
    _ref.read(selectTextServiceProvider.notifier).update((state) {
      return config;
    });
    _ref.read(textModelsProvider.notifier).update((state) {
      return config?.textConfig?.models ?? [];
    });
  }

  void setSpeechToTextServiceConfig(ServiceConfig? config) {
    _ref.read(selectSpeechToTextModelProvider.notifier).update((state) {
      if (_ref.read(selectSpeechToTextServiceProvider) != config) {
        return null;
      } else {
        return state;
      }
    });
    _ref.read(selectSpeechToTextServiceProvider.notifier).update((state) {
      return config;
    });
    _ref.read(speechToTextModelsProvider.notifier).update((state) {
      return config?.speechToTextConfig?.models ?? [];
    });
  }

  void setTextToSpeechServiceConfig(ServiceConfig? config) {
    _ref.read(selectTextToSpeechVoiceProvider.notifier).update((state) {
      if (_ref.read(selectTextToSpeechServiceProvider) != config) {
        return null;
      } else {
        return state;
      }
    });
    _ref.read(selectTextToSpeechServiceProvider.notifier).update((state) {
      return config;
    });
    _ref.read(textToSpeechVoicesProvider.notifier).update((state) {
      return config?.textToSpeechConfig?.voices ?? [];
    });
  }

  void setTextModel((String, String)? model) {
    _ref.read(selectTextModelProvider.notifier).update((state) {
      return model;
    });
  }

  void setSpeechToText((String, String)? model) {
    _ref.read(selectSpeechToTextModelProvider.notifier).update((state) {
      return model;
    });
  }

  void setTextToSpeech((String, String)? voice) {
    _ref.read(selectTextToSpeechVoiceProvider.notifier).update((state) {
      return voice;
    });
  }

  String? validationCheck() {
    final name = _ref.read(nameControllerProvider).text;
    if (name.isEmpty) {
      // return t.settings.serviceSettings.serviceConfig.error.nameIsRequired;
    }

    final selectTextService = _ref.read(selectTextServiceProvider);
    if (selectTextService == null) {
      // return t.settings.serviceSettings.serviceConfig.error.textServiceIsRequired;
    }

    final selectTextModel = _ref.read(selectTextModelProvider);
    if (selectTextModel == null) {
      // return t.settings.serviceSettings.serviceConfig.error.textModelIsRequired;
    }

    final selectSpeechToTextService =
        _ref.read(selectSpeechToTextServiceProvider);
    if (selectSpeechToTextService == null) {
      // return t.settings.serviceSettings.serviceConfig.error.speechToTextServiceIsRequired;
    }

    return null;
  }

  AgentConfig createAgentConfig() {
    return AgentConfig(
      id: _agentConfig?.id,
      name: _ref.read(nameControllerProvider).text,
      textServiceConfig: _ref.read(selectTextServiceProvider)!,
      textModel: _ref.read(selectTextModelProvider)!.$1,
      textModelName: _ref.read(selectTextModelProvider)!.$2,
      speechToTextServiceConfig: _ref.read(selectSpeechToTextServiceProvider)!,
      speechToTextModel: _ref.read(selectSpeechToTextModelProvider)!.$1,
      speechToTextModelName: _ref.read(selectSpeechToTextModelProvider)!.$2,
      textToSpeechServiceConfig: _ref.read(selectTextToSpeechServiceProvider)!,
      textToSpeechModel: _ref.read(selectTextToSpeechVoiceProvider)!.$1,
      textToSpeechModelName: _ref.read(selectTextToSpeechVoiceProvider)!.$2,
    );
  }
}
