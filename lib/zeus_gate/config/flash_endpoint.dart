import '../../zeus_vault/volt_cipher.dart';

// TODO: fill byte arrays via dart run tool/encode_creds.dart
String flashEndpointUrl() {
  const h = <int>[];
  const p = <int>[];
  if (h.isEmpty) return '';
  return decrypt(h) + decrypt(p);
}

const List<int> _gcdMask = <int>[];

String gcdUrl(String appId, String deviceId) {
  final host = decrypt(_gcdMask);
  if (host.isEmpty) return '';
  final sep = host.contains('?') ? '&' : '?';
  return '$host${sep}app_id=$appId&device_id=$deviceId';
}

String uaChromeBuild() => '136.0.7103.125';
String uaSafariBuild() => '605.1.15';
