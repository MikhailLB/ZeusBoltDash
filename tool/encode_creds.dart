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
/// The _seedBytes MUST match _seedBytes in lib/zeus_vault/volt_cipher.dart.
/// ════════════════════════════════════════════════════════════

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

final _stream = _buildKeyStream(64);

List<int> encode(String s) {
  final out = <int>[];
  for (var i = 0; i < s.length; i++) {
    out.add(s.codeUnitAt(i) ^ _stream[i % _stream.length]);
  }
  return out;
}

String fmt(List<int> v) => '[${v.join(', ')}]';

void main() {
  // ⚠️  FILL IN YOUR ACTUAL VALUES BELOW
  const configHost   = 'https://TODO_YOUR_DOMAIN.com';   // TODO
  const configPath   = '/config.php';
  const gcdHost      = 'https://gcdsdk.appsflyer.com/install_data/v4.0/';
  const appsflyerKey = 'TODO_APPSFLYER_DEV_KEY';         // TODO
  const firebaseProj = 'TODO_FIREBASE_PROJECT_NUMBER';   // TODO (numeric)
  const privacyUrl   = 'https://TODO_YOUR_DOMAIN.com/privacy-policy.html'; // TODO
  const supportUrl   = 'https://TODO_YOUR_DOMAIN.com/support.html';        // TODO

  print('// ── flash_endpoint.dart ─────────────────────────');
  print('const h = ${fmt(encode(configHost))};  // host');
  print('const p = ${fmt(encode(configPath))};  // path');
  print('');
  print('// ── flash_endpoint.dart — GCD ───────────────────');
  print('const _gcdMask = ${fmt(encode(gcdHost))};');
  print('');
  print('// ── volt_keys.dart — AppsFlyer key ───────────────');
  print('const v = ${fmt(encode(appsflyerKey))};');
  print('');
  print('// ── volt_keys.dart — Firebase project number ─────');
  print('const v = ${fmt(encode(firebaseProj))};');
  print('');
  print('// ── olympus_links.dart — privacy URL ─────────────');
  print('const _privacyMask = ${fmt(encode(privacyUrl))};');
  print('');
  print('// ── olympus_links.dart — support URL ─────────────');
  print('const _supportMask = ${fmt(encode(supportUrl))};');
  print('');
  print('// ── VERIFICATION ─────────────────────────────────');
  print('// configUrl  : $configHost$configPath');
  print('// afKey      : $appsflyerKey');
  print('// firebaseNum: $firebaseProj');
}
