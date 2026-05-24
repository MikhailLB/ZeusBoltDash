import 'dart:io';
import 'flash_endpoint.dart';
import 'volt_keys.dart';
import 'olympus_links.dart';

abstract final class BoltConfig {
  static const String iosStoreId = '6771217833';
  static const String bundleId   = 'com.zeusgames.zeus.bolt.dash';
  static const String appTitle   = 'Zeus Bolt Dash';

  static const int pushCooldownSeconds = 259200;
  static const int organicRetrySeconds = 6;

  static String get configEndpoint  => flashEndpointUrl();
  static String get installKey      => appsflyerVoltKey();
  static String get firebaseNumber  => firebaseProjectId();
  static String get privacyUrl      => olympusPrivacyUrl;
  static String get supportUrl      => olympusSupportUrl;
  static String get platformStoreId =>
      Platform.isIOS ? 'id$iosStoreId' : bundleId;
  static String get analyticsAppId  =>
      Platform.isIOS ? iosStoreId : bundleId;
}
