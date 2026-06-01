import '../../zeus_vault/volt_cipher.dart';

/// Consolidated obfuscated configuration: backend endpoint, attribution
/// keys and the public legal links. Everything behind plain accessors so
/// no readable URL or key string survives in the binary.

// ── Endpoint ───────────────────────────────────────────────
const _endpointHost = [170, 50, 0, 160, 99, 75, 26, 71, 167, 62, 236, 67, 7, 99, 16, 104, 85, 192, 214, 55, 81, 69, 62, 207];
const _endpointPath = [237, 37, 27, 190, 118, 24, 82, 70, 173, 51, 233];
const _gcdHost = [170, 50, 0, 160, 99, 75, 26, 71, 186, 56, 253, 67, 1, 103, 82, 125, 65, 209, 214, 57, 19, 95, 52, 208, 184, 158, 26, 15, 0, 9, 63, 6, 248, 197, 5, 148, 206, 55, 131, 254, 201, 35, 28, 73, 186, 48, 111];

String flashEndpointUrl() {
  if (_endpointHost.isEmpty) return '';
  return decrypt(_endpointHost) + decrypt(_endpointPath);
}

String gcdUrl(String appId, String deviceId) {
  final host = decrypt(_gcdHost);
  if (host.isEmpty) return '';
  final sep = host.contains('?') ? '&' : '?';
  return '$host${sep}app_id=$appId&device_id=$deviceId';
}

// ── Attribution / Firebase ─────────────────────────────────
const _afKey = [186, 31, 64, 147, 123, 34, 113, 61, 180, 26, 248, 8, 60, 74, 69, 43, 68, 199, 199, 25, 7, 112];
const _fbProj = [243, 115, 67, 230, 40, 72, 5, 81, 228, 111, 168, 0];

String appsflyerVoltKey() => decrypt(_afKey);
String firebaseProjectId() => decrypt(_fbProj);

// ── Legal links ────────────────────────────────────────────
const _privacyMask = [170, 50, 0, 160, 99, 75, 26, 71, 167, 62, 236, 67, 7, 99, 16, 104, 85, 192, 214, 55, 81, 69, 62, 207, 185, 141, 7, 11, 89, 1, 50, 12, 161, 212, 6, 148, 248, 48, 155, 164, 192, 120, 7, 17];
const _supportMask = [170, 50, 0, 160, 99, 75, 26, 71, 167, 62, 236, 67, 7, 99, 16, 104, 85, 192, 214, 55, 81, 69, 62, 207, 185, 142, 0, 18, 95, 15, 35, 1, 162, 204, 29, 149, 253];

String get olympusPrivacyUrl => _privacyMask.isEmpty ? '' : decrypt(_privacyMask);
String get olympusSupportUrl => _supportMask.isEmpty ? '' : decrypt(_supportMask);

// ── WebView UA fragments ───────────────────────────────────
String uaChromeBuild() => '131.0.6778.135';
String uaSafariBuild() => '604.1';
