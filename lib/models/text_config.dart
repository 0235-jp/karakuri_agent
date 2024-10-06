import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_config.freezed.dart';
part 'text_config.g.dart';

@freezed
class TextConfig with _$TextConfig {
  const factory TextConfig({
    required List<(String, String)> models,
  }) = _TextConfig;

  factory TextConfig.fromJson(Map<String, dynamic> json) =>
      _$TextConfigFromJson(json);
}
