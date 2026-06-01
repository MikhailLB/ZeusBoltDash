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
///
/// The seed + algorithm below MUST match lib/zeus_vault/volt_cipher.dart
/// exactly, otherwise decoded values come out as garbage.
/// ════════════════════════════════════════════════════════════

const _seed = <int>[
  0x3D, 0x9F, 0xA7, 0x2B, 0xE4, 0x16, 0x8C, 0x5F,
  0xD2, 0x7A, 0xB8, 0x04, 0x6E, 0xC3, 0x91, 0x5A,
  0xF7, 0x2D, 0x48, 0xBE, 0x63, 0x0C, 0x95,
];

const int _streamLen = 192;

Uint8List _buildStream(int size) {
  final box = List<int>.generate(256, (i) => i);
  var j = 0;
  for (var i = 0; i < 256; i++) {
    j = (j + box[i] + _seed[i % _seed.length]) & 0xFF;
    final t = box[i]; box[i] = box[j]; box[j] = t;
  }
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

final _stream = _buildStream(_streamLen);

List<int> encode(String s) {
  final n = _stream.length;
  final out = <int>[];
  for (var i = 0; i < s.length; i++) {
    out.add(s.codeUnitAt(i) ^ _stream[i % n]);
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
  print('const _endpointHost = ${fmt(encode(configHost))};');
  print('const _endpointPath = ${fmt(encode(configPath))};');
  print('');
  print('// ── GCD host ─────────────────────────────────────');
  print('const _gcdHost = ${fmt(encode(gcdHost))};');
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
