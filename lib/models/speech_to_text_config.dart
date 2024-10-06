import 'package:freezed_annotation/freezed_annotation.dart';

part 'speech_to_text_config.freezed.dart';
part 'speech_to_text_config.g.dart';

@freezed
class SpeechToTextConfig with _$SpeechToTextConfig {
  const factory SpeechToTextConfig({
    required List<(String, String)> models,
  }) = _SpeechToTextConfig;

  factory SpeechToTextConfig.fromJson(Map<String, dynamic> json) =>
      _$SpeechToTextConfigFromJson(json);
}
