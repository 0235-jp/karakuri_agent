import 'dart:io';
import 'dart:typed_data';

class AudioUtil {

  static Future<void> saveAsWav(List<int> buffer, String filePath, int sampleRate) async {
    // PCMデータの変換
    final bytes = Uint8List.fromList(buffer);
    final pcmData = Int16List.view(bytes.buffer);
    final byteBuffer = ByteData(pcmData.length * 2);
    const bitsPerSample = 16;
    const int numChannels = 1;

    for (var i = 0; i < pcmData.length; i++) {
      byteBuffer.setInt16(i * 2, pcmData[i], Endian.little);
    }

    final wavHeader = ByteData(44);
    final pcmBytes = byteBuffer.buffer.asUint8List();

    // RIFFチャンク
    wavHeader
      ..setUint8(0x00, 0x52) // 'R'
      ..setUint8(0x01, 0x49) // 'I'
      ..setUint8(0x02, 0x46) // 'F'
      ..setUint8(0x03, 0x46) // 'F'
      ..setUint32(4, 36 + pcmBytes.length, Endian.little) // ChunkSize
      ..setUint8(0x08, 0x57) // 'W'
      ..setUint8(0x09, 0x41) // 'A'
      ..setUint8(0x0A, 0x56) // 'V'
      ..setUint8(0x0B, 0x45) // 'E'
      ..setUint8(0x0C, 0x66) // 'f'
      ..setUint8(0x0D, 0x6D) // 'm'
      ..setUint8(0x0E, 0x74) // 't'
      ..setUint8(0x0F, 0x20) // ' '
      ..setUint32(16, 16, Endian.little) // Subchunk1Size
      ..setUint16(20, 1, Endian.little) // AudioFormat
      ..setUint16(22, numChannels, Endian.little) // NumChannels
      ..setUint32(24, sampleRate, Endian.little) // SampleRate
      ..setUint32(
        28,
        sampleRate * numChannels * bitsPerSample ~/ 8,
        Endian.little,
      ) // ByteRate
      ..setUint16(
        32,
        numChannels * bitsPerSample ~/ 8,
        Endian.little,
      ) // BlockAlign
      ..setUint16(34, bitsPerSample, Endian.little) // BitsPerSample

      // dataチャンク
      ..setUint8(0x24, 0x64) // 'd'
      ..setUint8(0x25, 0x61) // 'a'
      ..setUint8(0x26, 0x74) // 't'
      ..setUint8(0x27, 0x61) // 'a'
      ..setUint32(40, pcmBytes.length, Endian.little); // Subchunk2Size

    await File(filePath)
        .writeAsBytes(wavHeader.buffer.asUint8List() + pcmBytes);
  }

}