import 'dart:typed_data';

/// XOR-based string obfuscation for secrets stored as byte arrays.
///
/// Seed `zeus.bolt.dash.1` is unique to ZeusBoltDash — byte arrays
/// produced here are NOT interchangeable with any other project,
/// even for identical plaintext values.
const _seedBytes = <int>[
  0x7A, 0x65, 0x75, 0x73, 0x2E, 0x62, 0x6F, 0x6C,
  0x74, 0x2E, 0x64, 0x61, 0x73, 0x68, 0x2E, 0x31,
];

Uint8List _buildKeyStream(int size) {
  var hash = 0x811C9DC5;
  for (final b in _seedBytes) {
    hash = ((hash ^ b) * 0x01000193) & 0xFFFFFFFF;
  }
  final out = Uint8List(size);
  var state = hash == 0 ? 0x0A0520FF : hash;
  for (var i = 0; i < size; i++) {
    state = (state * 6364136223846793005 + 1442695040888963407) & 0x7FFFFFFF;
    out[i] = (state >> 13) & 0xFF;
  }
  return out;
}

final _keyStream = _buildKeyStream(64);

/// Decode an XOR-encoded byte list back to its plaintext string.
/// Use `tool/encode_creds.dart` to produce byte arrays for new values.
String decrypt(List<int> raw) {
  if (raw.isEmpty) return '';
  final n = _keyStream.length;
  final out = Uint8List(raw.length);
  for (var i = 0; i < raw.length; i++) {
    out[i] = raw[i] ^ _keyStream[i % n];
  }
  return String.fromCharCodes(out);
}
