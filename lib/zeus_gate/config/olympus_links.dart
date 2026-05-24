import '../../zeus_vault/volt_cipher.dart';

// TODO: fill byte arrays via dart run tool/encode_creds.dart
const List<int> _privacyMask = <int>[];
const List<int> _supportMask = <int>[];

String get olympusPrivacyUrl =>
    _privacyMask.isEmpty ? '' : decrypt(_privacyMask);

String get olympusSupportUrl =>
    _supportMask.isEmpty ? '' : decrypt(_supportMask);
