import 'deity.dart';
import '../../theme/aegis_palette.dart';

/// The four guardians of Olympus, each mapped to one of the bundled
/// character/arena art sets and a distinct ultimate.
class DeityCatalog {
  DeityCatalog._();

  static const Deity zeus = Deity(
    id: 'zeus',
    name: 'ZEUS',
    epithet: 'The Stormfather',
    characterAsset: 'assets/game_assets/zeus_01_asset.webp',
    arenaAsset: 'assets/game_assets/bg_01_asset.webp',
    accent: AegisPalette.skyBlue,
    ultimate: UltimateKind.chainLightning,
    ultimateName: 'CHAIN LIGHTNING',
    ultimateBlurb: 'A single bolt leaps between every threat and casts them out.',
    price: 0,
  );

  static const Deity poseidon = Deity(
    id: 'poseidon',
    name: 'POSEIDON',
    epithet: 'Lord of Tides',
    characterAsset: 'assets/game_assets/poseidon.webp',
    arenaAsset: 'assets/game_assets/bg_03_asset.webp',
    accent: AegisPalette.seaTeal,
    ultimate: UltimateKind.tidalSurge,
    ultimateName: 'TIDAL SURGE',
    ultimateBlurb: 'A radial wave hurls threats back and slows the tide of battle.',
    price: 1200,
  );

  static const Deity hades = Deity(
    id: 'hades',
    name: 'HADES',
    epithet: 'Keeper of Souls',
    characterAsset: 'assets/game_assets/aid.webp',
    arenaAsset: 'assets/game_assets/bg_02_asset.webp',
    accent: AegisPalette.underViolet,
    ultimate: UltimateKind.soulHarvest,
    ultimateName: 'SOUL HARVEST',
    ultimateBlurb: 'Nearby threats are bound into soul-shields that orbit and guard you.',
    price: 1800,
  );

  static const Deity prometheus = Deity(
    id: 'prometheus',
    name: 'PROMETHEUS',
    epithet: 'Bearer of Flame',
    characterAsset: 'assets/game_assets/prometey.webp',
    arenaAsset: 'assets/game_assets/bg_04_asset.webp',
    accent: AegisPalette.emberOrange,
    ultimate: UltimateKind.flameRing,
    ultimateName: 'FLAME RING',
    ultimateBlurb: 'A burning ring encircles the arena, incinerating all who enter.',
    price: 1500,
  );

  static const List<Deity> all = [zeus, poseidon, hades, prometheus];

  static Deity byId(String id) =>
      all.firstWhere((d) => d.id == id, orElse: () => zeus);
}
