import 'dart:typed_data';

/// String obfuscation for secrets stored as byte arrays.
///
/// The keystream is derived from a project-unique seed through a
/// SplitMix64 mixer, then combined with the ciphertext via XOR plus a
/// position-dependent drift term. The scheme is bespoke to ZeusBoltDash —
/// byte arrays produced here are not interchangeable with any sibling
/// build even for identical plaintext.
const _seed = <int>[
  0x61, 0x65, 0x67, 0x69, 0x73, 0x3A, 0x6F, 0x6C,
  0x79, 0x6D, 0x70, 0x75, 0x73, 0x3A, 0x76, 0x32,
  0x2D, 0x62, 0x6F, 0x6C, 0x74,
];

const int _streamLen = 96;
const int _mask64 = -1; // 0xFFFFFFFFFFFFFFFF as signed two's-complement

int _seedState() {
  var h = 0xCBF29CE484222325;
  for (final b in _seed) {
    h = (h ^ b) * 0x100000001B3;
  }
  return h & _mask64;
}

Uint8List _buildStream(int size) {
  var state = _seedState();
  final out = Uint8List(size);
  for (var i = 0; i < size; i++) {
    state = (state + 0x9E3779B97F4A7C15) & _mask64;
    var z = state;
    z = ((z ^ (z >>> 30)) * 0xBF58476D1CE4E5B9) & _mask64;
    z = ((z ^ (z >>> 27)) * 0x94D049BB133111EB) & _mask64;
    z = z ^ (z >>> 31);
    out[i] = z & 0xFF;
  }
  return out;
}

final Uint8List _stream = _buildStream(_streamLen);

int _drift(int i) => ((i * 0x3B) + 0x11) & 0xFF;

/// Decode an obfuscated byte list back to its plaintext string.
/// Produce new byte arrays with `tool/encode_creds.dart`.
String decrypt(List<int> raw) {
  if (raw.isEmpty) return '';
  final n = _stream.length;
  final out = Uint8List(raw.length);
  for (var i = 0; i < raw.length; i++) {
    out[i] = raw[i] ^ _stream[(i * 5 + 7) % n] ^ _drift(i);
  }
  return String.fromCharCodes(out);
}
