class PlayerData {
  int highScore;
  int coins;
  List<String> purchasedItems;
  String activeBg;
  String activeSkin;
  bool vibrationEnabled;
  int livesLevel;      // 0=3 lives, 1=4 lives, 2=5 lives
  int scoreLevel;      // 0=1x,     1=1.5x,    2=2x

  PlayerData({
    this.highScore = 0,
    this.coins = 0,
    List<String>? purchasedItems,
    this.activeBg = 'bg_01',
    this.activeSkin = 'zeus',
    this.vibrationEnabled = true,
    this.livesLevel = 0,
    this.scoreLevel = 0,
  }) : purchasedItems = purchasedItems ?? [];

  /// Max rocks the player can take before game over
  int get maxLives => 3 + livesLevel;

  /// Points multiplier
  double get scoreMultiplier => 1.0 + scoreLevel * 0.5;

  bool ownsItem(String itemId) =>
      itemId == 'bg_01' || itemId == 'zeus' || purchasedItems.contains(itemId);
}
