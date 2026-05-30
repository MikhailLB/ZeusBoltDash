import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'aegis_app.dart';
import 'core/system/orientation.dart' as orient;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start portrait-locked; the boot screen briefly unlocks landscape for its
  // intro video and then re-locks before the Sanctuary.
  await orient.Orientation.lockPortrait();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const AegisApp());
}
