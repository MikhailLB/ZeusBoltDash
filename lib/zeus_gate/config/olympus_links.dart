import '../../zeus_vault/volt_cipher.dart';

const List<int> _privacyMask = [121, 130, 205, 132, 147, 28, 102, 63, 183, 79, 135, 120, 234, 104, 224, 30, 241, 201, 126, 193, 71, 230, 223, 140, 165, 77, 99, 11, 196, 93, 44, 35, 192, 38, 70, 0, 223, 9, 88, 119, 118, 117, 241, 247];
const List<int> _supportMask = [121, 130, 205, 132, 147, 28, 102, 63, 183, 79, 135, 120, 234, 104, 224, 30, 241, 201, 126, 193, 71, 230, 223, 140, 165, 78, 100, 18, 194, 83, 61, 46, 195, 62, 93, 1, 218];

String get olympusPrivacyUrl =>
    _privacyMask.isEmpty ? '' : decrypt(_privacyMask);

String get olympusSupportUrl =>
    _supportMask.isEmpty ? '' : decrypt(_supportMask);
