abstract class TextToSpeechService {
  Future<void> speech(String text);

  void dispose();
}
