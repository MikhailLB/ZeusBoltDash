import '../../zeus_vault/volt_cipher.dart';

String appsflyerVoltKey() {
  const v = [105, 175, 141, 183, 139, 117, 13, 69, 164, 107, 147, 51, 209, 65, 181, 93, 224, 206, 111, 239, 17, 211];
  return decrypt(v);
}

String firebaseProjectId() {
  const v = [32, 195, 142, 194, 216, 31, 121, 41, 244, 30, 195, 59];
  return decrypt(v);
}
