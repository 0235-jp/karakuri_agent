import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/repositories/speech_to_text_repository.dart';

final speechToTextProvider = FutureProvider.autoDispose
    .family<SpeechToTextRepository?, (ServiceConfig, String)>(
        (ref, params) async {
  final speechToTextRepository =
      SpeechToTextRepository(ref, params.$1, params.$2);
  await speechToTextRepository.init();
  ref.onDispose(() {
    speechToTextRepository.dispose();
  });
  return speechToTextRepository;
});
