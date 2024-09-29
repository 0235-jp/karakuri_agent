import 'dart:io';
abstract class SpeechToTextService {
  Future<String> createTranscription(String model, File audioFile);
}
