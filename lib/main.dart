import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/storage_service.dart';
import 'services/vibration_service.dart';
import 'services/orientation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await OrientationService.lockPortrait();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Future.wait([
    StorageService.instance.init(),
    VibrationService.instance.init(),
  ]);

  runApp(const ZeusBoltDashApp());
}
