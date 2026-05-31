// ignore_for_file: avoid_print
import 'dart:typed_data';

/// ════════════════════════════════════════════════════════════
/// ZeusBoltDash — credential encoder
/// ════════════════════════════════════════════════════════════
///
/// USAGE:
///   dart run tool/encode_creds.dart
///
/// ⚠️  Always run with `dart run`, NEVER PowerShell foreach loops.
/// PowerShell overflows 32-bit integers → wrong byte values.
///
/// The seed + mixing below MUST match lib/zeus_vault/volt_cipher.dart
/// exactly, otherwise decoded values come out as garbage.
/// ════════════════════════════════════════════════════════════

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

Uint8List _streamBytes(int size) {
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

final _stream = _streamBytes(_streamLen);

int _drift(int i) => ((i * 0x3B) + 0x11) & 0xFF;

List<int> encode(String s) {
  final n = _stream.length;
  final out = <int>[];
  for (var i = 0; i < s.length; i++) {
    out.add(s.codeUnitAt(i) ^ _stream[(i * 5 + 7) % n] ^ _drift(i));
  }
  return out;
}

String fmt(List<int> v) => '[${v.join(', ')}]';

void main() {
  // ⚠️  FILL IN YOUR ACTUAL VALUES BELOW
  const configHost   = 'https://zeusboltdash.com';
  const configPath   = '/config.php';
  const gcdHost      = 'https://gcdsdk.appsflyer.com/install_data/v4.0/';
  const appsflyerKey = 'xY4CkSDUiAa8YF97ufbFxV';
  const firebaseProj = '157689099410';
  const privacyUrl   = 'https://zeusboltdash.com/privacy-policy.html';
  const supportUrl   = 'https://zeusboltdash.com/support.html';

  print('// ── endpoint host + path ─────────────────────────');
  print('const h = ${fmt(encode(configHost))};');
  print('const p = ${fmt(encode(configPath))};');
  print('');
  print('// ── GCD host ─────────────────────────────────────');
  print('const _gcdMask = ${fmt(encode(gcdHost))};');
  print('');
  print('// ── AppsFlyer key ────────────────────────────────');
  print('const _afKey = ${fmt(encode(appsflyerKey))};');
  print('');
  print('// ── Firebase project number ──────────────────────');
  print('const _fbProj = ${fmt(encode(firebaseProj))};');
  print('');
  print('// ── privacy URL ──────────────────────────────────');
  print('const _privacyMask = ${fmt(encode(privacyUrl))};');
  print('');
  print('// ── support URL ──────────────────────────────────');
  print('const _supportMask = ${fmt(encode(supportUrl))};');
  print('');
  print('// ── VERIFICATION ─────────────────────────────────');
  print('// configUrl  : $configHost$configPath');
  print('// afKey      : $appsflyerKey');
  print('// firebaseNum: $firebaseProj');
}
