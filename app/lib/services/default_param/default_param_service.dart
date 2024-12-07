import 'package:karakuri_agent/models/key_value_pair.dart';

abstract class DefaultParamService {
  List<KeyValuePair> get textModels;
  List<KeyValuePair> get speechToTextModels;
  List<KeyValuePair> get textToSpeechModels;
  List<KeyValuePair> get textToSpeechVoices;
}
