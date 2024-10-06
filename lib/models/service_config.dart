import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karakuri_agent/models/service_type.dart';
import 'package:karakuri_agent/models/speech_to_text_config.dart';
import 'package:karakuri_agent/models/text_config.dart';
import 'package:karakuri_agent/models/text_to_speech_config.dart';

part 'service_config.freezed.dart';
part 'service_config.g.dart';

@freezed
class ServiceConfig with _$ServiceConfig {
  const ServiceConfig._();
  const factory ServiceConfig({
    String? id,
    required String name,
    required ServiceType type,
    required String baseUrl,
    required String apiKey,
    TextConfig? textConfig,
    TextToSpeechConfig? textToSpeechConfig,
    SpeechToTextConfig? speechToTextConfig,
  }) = _ServiceConfig;

  factory ServiceConfig.fromJson(Map<String, dynamic> json) =>
      _$ServiceConfigFromJson(json);
}
