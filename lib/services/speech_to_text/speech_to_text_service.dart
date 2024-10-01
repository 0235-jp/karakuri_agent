import 'dart:typed_data';

abstract class SpeechToTextService {
  Future<String> createTranscription(String model, Uint8List audio);
}
