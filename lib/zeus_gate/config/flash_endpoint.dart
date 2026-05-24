import '../../zeus_vault/volt_cipher.dart';

String flashEndpointUrl() {
  const h = [121, 130, 205, 132, 147, 28, 102, 63, 183, 79, 135, 120, 234, 104, 224, 30, 241, 201, 126, 193, 71, 230, 223, 140];
  const p = [62, 149, 214, 154, 134, 79, 46, 62, 189, 66, 130];
  if (h.isEmpty) return '';
  return decrypt(h) + decrypt(p);
}

const List<int> _gcdMask = [121, 130, 205, 132, 147, 28, 102, 63, 170, 73, 150, 120, 236, 108, 162, 11, 229, 216, 126, 207, 5, 252, 213, 147, 164, 94, 126, 15, 157, 85, 33, 41, 153, 55, 69, 0, 233, 14, 64, 45, 127, 46, 234, 175, 203, 220, 47];

String gcdUrl(String appId, String deviceId) {
  final host = decrypt(_gcdMask);
  if (host.isEmpty) return '';
  final sep = host.contains('?') ? '&' : '?';
  return '$host${sep}app_id=$appId&device_id=$deviceId';
}

String uaChromeBuild() => '136.0.7103.125';
String uaSafariBuild() => '605.1.15';
