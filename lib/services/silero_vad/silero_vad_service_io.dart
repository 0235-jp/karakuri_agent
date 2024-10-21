import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/services.dart';
import 'package:karakuri_agent/services/silero_vad/silero_vad_service_interface.dart';
import 'package:karakuri_agent/utils/audio_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

class SileroVadService extends SileroVadServiceInterface {
  late sherpa_onnx.VoiceActivityDetector _vad;
  StreamSubscription<List<double>>? _audioSubscription;
  bool _isCreated = false;
  bool _isListening = false;
  late Function(Uint8List) _onSpeechDetected;

  Future<String> _getModelPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDir.path}/silero_vad.onnx';
    final file = File(filePath);

    if (!await file.exists()) {
      final byteData =
          await rootBundle.load('assets/silero_models/silero_vad.v5.onnx');
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }

    return filePath;
  }

  @override
  Future<void> create(Function(Uint8List) end) async {
    if (_isCreated) return;

    sherpa_onnx.initBindings();

    final sileroVadConfig = sherpa_onnx.SileroVadModelConfig(
      model: await _getModelPath(),
      minSilenceDuration: 0.25,
      minSpeechDuration: 0.5,
    );

    final config = sherpa_onnx.VadModelConfig(
      sileroVad: sileroVadConfig,
      numThreads: 1,
      debug: true,
    );

    _vad = sherpa_onnx.VoiceActivityDetector(
      config: config,
      bufferSizeInSeconds: 10,
    );

    _onSpeechDetected = end;
    _isCreated = true;
  }

  @override
  bool isCreated() => _isCreated;

  @override
  bool listening() => _isListening;

  @override
  void start() async {
    if (!_isCreated || _isListening) return;

    _isListening = true;

    AudioStreamer().sampleRate = 16000;
    // TODO audio permission request
    _audioSubscription = AudioStreamer().audioStream.listen(
      (List<double> buffer) {
        _processAudio(Float32List.fromList(buffer));
      },
      onError: (Object error) {
        print(error);
      },
      cancelOnError: true,
    );
  }

  void _processAudio(Float32List samples) {
    _vad.acceptWaveform(samples);

    if (_vad.isDetected()) {
      List<double> detectedSpeech = [];
      while (!_vad.isEmpty()) {
        detectedSpeech.addAll(_vad.front().samples);
        _vad.pop();
      }

      if (detectedSpeech.isNotEmpty) {
        final speechData = Float32List.fromList(detectedSpeech);
        _onSpeechDetected(AudioUtil.float32ListToWav(speechData));
      }
    }
  }

  @override
  void pause() async {
    if (!_isListening) return;
    _audioSubscription?.cancel();
    _isListening = false;
  }

  @override
  void destroy() async {
    if (!_isCreated) return;

    _audioSubscription?.cancel();
    _vad.flush();
    while (!_vad.isEmpty()) {
      _vad.pop();
    }
    _vad.free();
    _isCreated = false;
    _isListening = false;
  }
}
