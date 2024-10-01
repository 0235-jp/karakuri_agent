import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/models/service_type.dart';
import 'package:karakuri_agent/providers/voice_activity_detection_provider.dart';
import 'package:karakuri_agent/repositories/voice_activity_detaction_repository.dart';
import 'package:karakuri_agent/services/speech_to_text/speech_to_text_openai_service.dart';
import 'package:karakuri_agent/services/speech_to_text/speech_to_text_service.dart';

class SpeechToTextRepository {
  final speechToTextResultProvider = StateProvider<String?>((ref) => null);
  final AutoDisposeFutureProviderRef _ref;
  final ServiceConfig _serviceConfig;
  final String _model;
  late VoiceActivityDetectionRepository _voiceActivityDetectionRepository;
  late SpeechToTextService _service;

  SpeechToTextRepository(this._ref, this._serviceConfig, this._model);

  Future<void> init() async {
    _voiceActivityDetectionRepository = await _ref.watch(
        voiceActivityDetectionProvider((audio) => _createTranscription(audio))
            .future);
    switch (_serviceConfig.type) {
      case ServiceType.openAI:
        _service = SpeechToTextOpenaiService(_serviceConfig);
        break;
      default:
        throw Exception('Service type not supported');
    }
  }

  Future<void> dispose() async {
    _ref.read(speechToTextResultProvider.notifier).dispose();
  }

  void startRecognition() {
    _ref.read(speechToTextResultProvider.notifier).state = null;
    _voiceActivityDetectionRepository.start();
  }

  void pauseRecognition() {
    _ref.read(speechToTextResultProvider.notifier).state = null;
    _voiceActivityDetectionRepository.pause();
  }

  Future<void> _createTranscription(Uint8List audio) async {
    final text = await _service.createTranscription(_model, audio);
    _ref.read(speechToTextResultProvider.notifier).state = text;
  }
}
