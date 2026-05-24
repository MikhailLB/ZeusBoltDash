import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../widgets/shop_item_card.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late int _coins;
  late List<String> _owned;
  late String _activeBg;
  late String _activeSkin;
  late int _livesLevel;
  late int _scoreLevel;

  // ── Backgrounds ─────────────────────────────────────────────────
  static const _bgs = [
    _ShopItem(id: 'bg_01', name: 'Olympus', price: 0,
        asset: 'assets/game_assets/bg_01_asset.webp'),
    _ShopItem(id: 'bg_02', name: 'Underworld', price: 100,
        asset: 'assets/game_assets/bg_02_asset.webp'),
    _ShopItem(id: 'bg_03', name: 'Ocean Realm', price: 250,
        asset: 'assets/game_assets/bg_03_asset.webp'),
    _ShopItem(id: 'bg_04', name: 'War Fields', price: 500,
        asset: 'assets/game_assets/bg_04_asset.webp'),
  ];

  // ── Character skins (actual asset files) ────────────────────────
  static const _skins = [
    _ShopItem(id: 'zeus', name: 'Zeus', price: 0,
        asset: 'assets/game_assets/zeus_01_asset.webp'),
    _ShopItem(id: 'poseidon', name: 'Poseidon', price: 300,
        asset: 'assets/game_assets/poseidon.webp'),
    _ShopItem(id: 'aid', name: 'Hades', price: 400,
        asset: 'assets/game_assets/aid.webp'),
    _ShopItem(id: 'prometey', name: 'Prometheus', price: 500,
        asset: 'assets/game_assets/prometey.webp'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    final data = StorageService.instance.loadPlayerData();
    _coins = data.coins;
    _owned = List.from(data.purchasedItems);
    _activeBg = data.activeBg;
    _activeSkin = data.activeSkin;
    _livesLevel = data.livesLevel;
    _scoreLevel = data.scoreLevel;
  }

  // ── Upgrade costs ─────────────────────────────────────────────────
  static const _livesCosts = [0, 200, 500]; // cost to reach level 0,1,2
  static const _scoreCosts = [0, 300, 700];

  Future<void> _upgradeLives() async {
    if (_livesLevel >= 2) return;
    final cost = _livesCosts[_livesLevel + 1];
    if (_coins < cost) return;
    await StorageService.instance.spendCoins(cost);
    await StorageService.instance.setLivesLevel(_livesLevel + 1);
    setState(() {
      _coins -= cost;
      _livesLevel++;
    });
  }

  Future<void> _upgradeScore() async {
    if (_scoreLevel >= 2) return;
    final cost = _scoreCosts[_scoreLevel + 1];
    if (_coins < cost) return;
    await StorageService.instance.spendCoins(cost);
    await StorageService.instance.setScoreLevel(_scoreLevel + 1);
    setState(() {
      _coins -= cost;
      _scoreLevel++;
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  bool _ownsItem(String id) =>
      id == 'bg_01' || id == 'zeus' || _owned.contains(id);

  Future<void> _buy(String id, int price, bool isBg) async {
    if (_coins < price || _ownsItem(id)) return;
    await StorageService.instance.spendCoins(price);
    await StorageService.instance.purchaseItem(id);
    if (isBg) {
      await StorageService.instance.setActiveBg(id);
    } else {
      await StorageService.instance.setActiveSkin(id);
    }
    setState(() {
      _coins -= price;
      if (!_owned.contains(id)) _owned.add(id);
      if (isBg) _activeBg = id; else _activeSkin = id;
    });
  }

  Future<void> _equip(String id, bool isBg) async {
    if (isBg) {
      await StorageService.instance.setActiveBg(id);
      setState(() => _activeBg = id);
    } else {
      await StorageService.instance.setActiveSkin(id);
      setState(() => _activeSkin = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0520),
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildGrid(_bgs, _activeBg, isBg: true),
                _buildGrid(_skins, _activeSkin, isBg: false),
                _buildUpgradesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0A40), Color(0xFF0A0520)],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFD4A017), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1A50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6A5A90)),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Color(0xFFD4A017), size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'SHOP',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFFD700),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1A50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4A017)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 6),
                Text(
                  '$_coins',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF1A0A40),
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: const Color(0xFFD4A017),
        labelColor: const Color(0xFFFFD700),
        unselectedLabelColor: const Color(0xFF6A5A90),
        labelStyle: GoogleFonts.cinzel(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5),
        unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 13),
        tabs: const [
          Tab(text: 'BACKGROUNDS'),
          Tab(text: 'HEROES'),
          Tab(text: 'UPGRADES'),
        ],
      ),
    );
  }

  Widget _buildGrid(
      List<_ShopItem> items, String activeId, {required bool isBg}) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final owned = _ownsItem(item.id);
        return ShopItemCard(
          preview: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              item.asset,
              height: 110,
              width: double.infinity,
              fit: isBg ? BoxFit.cover : BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image,
                    color: Color(0xFF6A5A90), size: 40),
              ),
            ),
          ),
          name: item.name,
          price: item.price,
          owned: owned,
          equipped: activeId == item.id,
          canAfford: _coins >= item.price,
          onBuy: () => _buy(item.id, item.price, isBg),
          onEquip: () => _equip(item.id, isBg),
        );
      },
    );
  }

  // ── Upgrades tab ─────────────────────────────────────────────────
  Widget _buildUpgradesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUpgradeCard(
            icon: Icons.favorite,
            iconColor: Colors.red,
            title: 'LIVES',
            description: 'Increase max lives before game over',
            currentLevel: _livesLevel,
            maxLevel: 2,
            levelLabels: ['3 Lives', '4 Lives', '5 Lives'],
            costs: _livesCosts,
            canAfford: _livesLevel < 2 &&
                _coins >= _livesCosts[(_livesLevel + 1).clamp(0, 2)],
            onUpgrade: _upgradeLives,
          ),
          const SizedBox(height: 16),
          _buildUpgradeCard(
            icon: Icons.bolt,
            iconColor: const Color(0xFFFFD700),
            title: 'SCORE BOOST',
            description: 'Multiply points earned from lightnings',
            currentLevel: _scoreLevel,
            maxLevel: 2,
            levelLabels: ['×1.0', '×1.5', '×2.0'],
            costs: _scoreCosts,
            canAfford: _scoreLevel < 2 &&
                _coins >= _scoreCosts[(_scoreLevel + 1).clamp(0, 2)],
            onUpgrade: _upgradeScore,
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required int currentLevel,
    required int maxLevel,
    required List<String> levelLabels,
    required List<int> costs,
    required bool canAfford,
    required VoidCallback onUpgrade,
  }) {
    final isMaxed = currentLevel >= maxLevel;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1A50), Color(0xFF1A0A30)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMaxed
              ? const Color(0xFFD4A017)
              : const Color(0xFF6A5A90),
          width: isMaxed ? 2 : 1,
        ),
        boxShadow: isMaxed
            ? [
                BoxShadow(
                  color: const Color(0xFFD4A017).withAlpha(60),
                  blurRadius: 12,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFFD700),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (isMaxed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFD4A017)),
                  ),
                  child: Text(
                    'MAX',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFD4A017),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.cinzel(
              color: const Color(0xFF9A8AC0),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),

          // Level dots
          Row(
            children: List.generate(maxLevel + 1, (i) {
              final active = i <= currentLevel;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < maxLevel ? 6 : 0),
                  height: 36,
                  decoration: BoxDecoration(
                    color: active
                        ? iconColor.withAlpha(40)
                        : const Color(0xFF1A0A30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active
                          ? iconColor
                          : const Color(0xFF4A3A70),
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      levelLabels[i],
                      style: GoogleFonts.cinzel(
                        color: active
                            ? iconColor
                            : const Color(0xFF4A3A70),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Upgrade button
          if (!isMaxed)
            GestureDetector(
              onTap: canAfford ? onUpgrade : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: canAfford
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF8B6914),
                            Color(0xFFD4A017),
                          ],
                        )
                      : const LinearGradient(
                          colors: [
                            Color(0xFF3A3A3A),
                            Color(0xFF2A2A2A),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: canAfford
                        ? const Color(0xFFD4A017)
                        : const Color(0xFF555555),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: canAfford
                          ? Colors.white
                          : const Color(0xFF777777),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'UPGRADE',
                      style: GoogleFonts.cinzel(
                        color: canAfford
                            ? Colors.white
                            : const Color(0xFF777777),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.monetization_on,
                        color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${costs[(currentLevel + 1).clamp(0, maxLevel)]}',
                      style: GoogleFonts.cinzel(
                        color: canAfford
                            ? const Color(0xFFFFD700)
                            : const Color(0xFF777777),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopItem {
  final String id;
  final String name;
  final int price;
  final String asset;
  const _ShopItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.asset});
}
