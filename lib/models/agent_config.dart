import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karakuri_agent/models/service_config.dart';

part 'agent_config.freezed.dart';
part 'agent_config.g.dart';

@freezed
class AgentConfig with _$AgentConfig {
  const factory AgentConfig({
    String? id,
    required String name,
    required ServiceConfig textServiceConfig,
    required String textModel,
    required String textModelName,
    required ServiceConfig speechToTextServiceConfig,
    required String speechToTextModel,
    required String speechToTextModelName,
    required ServiceConfig textToSpeechServiceConfig,
    required String textToSpeechModel,
    required String textToSpeechModelName,
  }) = _AgentConfig;

  factory AgentConfig.fromJson(Map<String, dynamic> json) =>
      _$AgentConfigFromJson(json);
}
