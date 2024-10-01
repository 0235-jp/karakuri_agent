import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/providers/speech_to_text_provider.dart';
import 'package:karakuri_agent/repositories/config_storage_repository.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/repositories/speech_to_text_repository.dart';

class TalkScreenViewmodel {
  final AutoDisposeRef _ref;
  final String _serviceId;
  final String _modelId;
  final ConfigStorageRepository _configStorage;
  final serviceConfigProvider = StateProvider<ServiceConfig?>((ref) => null);
  final isListningProvider = StateProvider<bool>((ref) => false);
  late SpeechToTextRepository? speechToTextRepository;
  late StateProvider<String?> textProvider;

  TalkScreenViewmodel(
      this._ref, this._serviceId, this._modelId, this._configStorage);

  Future<void> build() async {
    final serviceConfif = await _configStorage.loadConfig(_serviceId);

    speechToTextRepository = await _ref.watch(speechToTextProvider(
            (serviceConfif, _modelId) as (ServiceConfig, String))
        .future);
    textProvider = StateProvider<String?>(
        (ref) => ref.watch(speechToTextRepository!.speechToTextResultProvider));
    _ref.read(serviceConfigProvider.notifier).state = serviceConfif;
  }

  void start() {
    _ref.read(isListningProvider.notifier).state = true;
    speechToTextRepository?.startRecognition();
  }

  void pause() {
    speechToTextRepository?.pauseRecognition();
    _ref.read(isListningProvider.notifier).state = false;
  }

  void dispose() {
    _ref.read(serviceConfigProvider.notifier).dispose();
    _ref.read(isListningProvider.notifier).dispose();
    _ref.read(textProvider.notifier).dispose();
  }
}
