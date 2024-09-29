import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/services/speech_to_text/speech_to_text_service.dart';
import 'package:karakuri_agent/utils/language_util.dart';

class SpeechToTextOpenaiService extends SpeechToTextService {
  final ServiceConfig _serviceConfig;

  SpeechToTextOpenaiService(this._serviceConfig);

  @override
  Future<String> createTranscription(String model, File audioFile) async {
    OpenAI.baseUrl = _serviceConfig.baseUrl;
    OpenAI.apiKey = _serviceConfig.apiKey;
    return await OpenAI.instance.audio
        .createTranscription(
            file: audioFile,
            model: model,
            language: LanguageUtil.isoLanguageCode)
        .then((result) => result.text);
  }
}
