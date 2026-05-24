import '../../zeus_vault/volt_cipher.dart';

// TODO: fill byte arrays via dart run tool/encode_creds.dart
String appsflyerVoltKey() {
  const v = <int>[];
  if (v.isEmpty) return '';
  return decrypt(v);
}

String firebaseProjectId() {
  const v = <int>[];
  if (v.isEmpty) return '';
  return decrypt(v);
}
