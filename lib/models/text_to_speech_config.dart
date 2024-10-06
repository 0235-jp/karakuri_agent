import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_to_speech_config.freezed.dart';
part 'text_to_speech_config.g.dart';

@freezed
class TextToSpeechConfig with _$TextToSpeechConfig {
  const factory TextToSpeechConfig({
    required List<(String, String)> voices,
  }) = _TextToSpeechConfig;

  factory TextToSpeechConfig.fromJson(Map<String, dynamic> json) =>
      _$TextToSpeechConfigFromJson(json);
}
