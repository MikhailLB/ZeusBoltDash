import '../../zeus_vault/volt_cipher.dart';

/// Consolidated obfuscated configuration: backend endpoint, attribution
/// keys and the public legal links. Everything that used to live across
/// several tiny config units is gathered here behind plain accessors so
/// no readable URL or key string survives in the binary.

// ── Endpoint ───────────────────────────────────────────────
const _endpointHost = [63, 120, 114, 93, 190, 108, 212, 82, 2, 83, 28, 177, 237, 175, 106, 51, 133, 204, 135, 127, 77, 175, 247, 166];
const _endpointPath = [120, 111, 105, 67, 171, 63, 156, 83, 8, 94, 25];
const _gcdHost = [63, 120, 114, 93, 190, 108, 212, 82, 31, 85, 13, 177, 235, 171, 40, 38, 145, 221, 135, 113, 15, 181, 253, 185, 161, 192, 199, 60, 217, 178, 136, 213, 165, 102, 85, 226, 234, 100, 71, 79, 5, 100, 160, 8, 41, 93, 240];

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
const _afKey = [47, 85, 50, 110, 166, 5, 191, 40, 17, 119, 8, 250, 214, 134, 63, 112, 148, 203, 150, 81, 27, 154];
const _fbProj = [102, 57, 49, 27, 245, 111, 203, 68, 65, 2, 88, 242];

String appsflyerVoltKey() => decrypt(_afKey);
String firebaseProjectId() => decrypt(_fbProj);

// ── Legal links ────────────────────────────────────────────
const _privacyMask = [63, 120, 114, 93, 190, 108, 212, 82, 2, 83, 28, 177, 237, 175, 106, 51, 133, 204, 135, 127, 77, 175, 247, 166, 160, 211, 218, 56, 128, 186, 133, 223, 252, 119, 86, 226, 220, 99, 95, 21, 12, 63, 187, 80];
const _supportMask = [63, 120, 114, 93, 190, 108, 212, 82, 2, 83, 28, 177, 237, 175, 106, 51, 133, 204, 135, 127, 77, 175, 247, 166, 160, 208, 221, 33, 134, 180, 148, 210, 255, 111, 77, 227, 217];

String get olympusPrivacyUrl => _privacyMask.isEmpty ? '' : decrypt(_privacyMask);
String get olympusSupportUrl => _supportMask.isEmpty ? '' : decrypt(_supportMask);

// ── WebView UA fragments ───────────────────────────────────
String uaChromeBuild() => '136.0.7103.125';
String uaSafariBuild() => '605.1.15';
