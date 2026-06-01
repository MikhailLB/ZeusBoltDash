import 'dart:typed_data';

/// String obfuscation for secrets stored as byte arrays.
///
/// Uses an RC4-style KSA/PRGA keystream — a completely different algorithm
/// family from SplitMix64, producing distinct machine code even for the
/// same plaintext inputs.
const _seed = <int>[
  0x3D, 0x9F, 0xA7, 0x2B, 0xE4, 0x16, 0x8C, 0x5F,
  0xD2, 0x7A, 0xB8, 0x04, 0x6E, 0xC3, 0x91, 0x5A,
  0xF7, 0x2D, 0x48, 0xBE, 0x63, 0x0C, 0x95,
];

const int _streamLen = 192;

Uint8List _buildStream(int size) {
  // KSA — key-scheduling algorithm
  final box = List<int>.generate(256, (i) => i);
  var j = 0;
  for (var i = 0; i < 256; i++) {
    j = (j + box[i] + _seed[i % _seed.length]) & 0xFF;
    final t = box[i]; box[i] = box[j]; box[j] = t;
  }
  // PRGA — pseudo-random generation algorithm
  final out = Uint8List(size);
  var x = 0; var y = 0;
  for (var k = 0; k < size; k++) {
    x = (x + 1) & 0xFF;
    y = (y + box[x]) & 0xFF;
    final t = box[x]; box[x] = box[y]; box[y] = t;
    out[k] = box[(box[x] + box[y]) & 0xFF];
  }
  return out;
}

final Uint8List _stream = _buildStream(_streamLen);

/// Decode an obfuscated byte list back to its plaintext string.
/// Produce new byte arrays with `tool/encode_creds.dart`.
String decrypt(List<int> raw) {
  if (raw.isEmpty) return '';
  final n = _stream.length;
  final out = Uint8List(raw.length);
  for (var i = 0; i < raw.length; i++) {
    out[i] = raw[i] ^ _stream[i % n];
  }
  return String.fromCharCodes(out);
}
