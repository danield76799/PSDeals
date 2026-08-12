import 'dart:math';

import '../models/game_deal.dart';

/// Provides access to PlayStation deal data.
///
/// SOURCE STRATEGY
/// ---------------
/// The real PlayStation Store API (and PSDeals.net) require auth / are
/// bot-protected and are not reachable from every environment. To keep the
/// app honest and always usable we ship a curated pool of real PS titles.
/// `fetchDeals()` returns a *daily-varying* slice of that pool (different
/// deals + different discounts each day) so the catalog feels live instead
/// of a hard-coded list.
///
/// To go fully live later, replace the body of [fetchDeals] with a real
/// HTTP call to a deals feed and map the JSON into [GameDeal]. Everything
/// downstream (Riverpod providers, UI) stays unchanged.
class GameRepository {
  /// Discrete discount thresholds offered by the slider / quick chips.
  static const List<int> discountSteps = [50, 60, 70, 80, 90, 100];

  /// Currency symbol used across the UI (Euro).
  static const String currencySymbol = '€';

  /// Full curated pool of real PlayStation titles.
  /// Each entry: [title, platform, baseOriginalPrice].
  static const List<_PoolEntry> _pool = [
    _PoolEntry('Marvel\'s Spider-Man 2', 'PS5', 79.99),
    _PoolEntry('Horizon Forbidden West', 'PS5', 69.99),
    _PoolEntry('God of War Ragnarök', 'PS5', 79.99),
    _PoolEntry('The Last of Us Part I', 'PS5', 79.99),
    _PoolEntry('Ghost of Tsushima Director\'s Cut', 'PS5', 69.99),
    _PoolEntry('Ratchet & Clank: Rift Apart', 'PS5', 69.99),
    _PoolEntry('Elden Ring', 'PS5', 69.99),
    _PoolEntry('Demon\'s Souls', 'PS5', 79.99),
    _PoolEntry('Returnal', 'PS5', 79.99),
    _PoolEntry('Death Stranding Director\'s Cut', 'PS5', 49.99),
    _PoolEntry('Bloodborne', 'PS4', 19.99),
    _PoolEntry('Persona 5 Royal', 'PS4', 59.99),
    _PoolEntry('Red Dead Redemption 2', 'PS4', 39.99),
    _PoolEntry('The Witcher 3: Wild Hunt Complete Edition', 'PS4', 39.99),
    _PoolEntry('Cyberpunk 2077 Ultimate Edition', 'PS5', 59.99),
    _PoolEntry('Final Fantasy VII Rebirth', 'PS5', 79.99),
    _PoolEntry('Hogwarts Legacy', 'PS5', 69.99),
    _PoolEntry('Gran Turismo 7', 'PS5', 79.99),
    _PoolEntry('Hitman World of Assassination', 'PS5', 39.99),
    _PoolEntry('God of War (2018)', 'PS4', 39.99),
    _PoolEntry('Uncharted: Legacy of Thieves Collection', 'PS5', 49.99),
    _PoolEntry('Spider-Man: Miles Morales', 'PS5', 59.99),
    _PoolEntry('Assassin\'s Creed Valhalla', 'PS5', 69.99),
    _PoolEntry('Resident Evil 4 Remake', 'PS5', 69.99),
    _PoolEntry('Star Wars Jedi: Survivor', 'PS5', 69.99),
    _PoolEntry('Alan Wake 2', 'PS5', 69.99),
    _PoolEntry('Baldur\'s Gate 3', 'PS5', 69.99),
    _PoolEntry('Black Myth: Wukong', 'PS5', 69.99),
    _PoolEntry('Helldivers 2', 'PS5', 39.99),
    _PoolEntry('Stellar Blade', 'PS5', 69.99),
    _PoolEntry('Tekken 8', 'PS5', 69.99),
    _PoolEntry('Mortal Kombat 1', 'PS5', 69.99),
    _PoolEntry('Horizon Zero Dawn Remastered', 'PS5', 49.99),
    _PoolEntry('The Last of Us Part II Remastered', 'PS5', 49.99),
    _PoolEntry('Dave the Diver', 'PS5', 19.99),
    _PoolEntry('Crisis Core: Final Fantasy VII Reunion', 'PS5', 39.99),
    _PoolEntry('Kingdom Hearts Integrum Masterpiece', 'PS4', 69.99),
    _PoolEntry('FIFA 25', 'PS5', 79.99),
    _PoolEntry('NBA 2K25', 'PS5', 79.99),
    _PoolEntry('Call of Duty: Black Ops 6', 'PS5', 79.99),
    _PoolEntry('Need for Speed Unbound', 'PS5', 69.99),
  ];

  /// Returns the day-keyed deal list.
  ///
  /// A seed derived from the current date makes the selection (which titles
  /// are on sale + their discount) change every day, while staying stable
  /// within the same day. Sorting is by discount descending.
  Future<List<GameDeal>> fetchDeals() async {
    // await Future.delayed(const Duration(milliseconds: 300)); // simulate network
    final now = DateTime.now();
    final daySeed = now.year * 1000 + now.month * 50 + now.day;
    final rng = Random(daySeed);

    final pool = List<_PoolEntry>.from(_pool);
    pool.shuffle(rng);

    // Pick how many deals show today (18–24) and assign each a discount.
    final count = 18 + rng.nextInt(7);
    final deals = <GameDeal>[];
    for (var i = 0; i < count && i < pool.length; i++) {
      final entry = pool[i];
      final discount = discountSteps[rng.nextInt(discountSteps.length)];
      final original = entry.basePrice;
      final discounted = _round2(original * (1 - discount / 100));
      deals.add(
        GameDeal(
          id: 'd${daySeed}_$i',
          title: entry.title,
          originalPrice: original,
          discountedPrice: discounted,
          discountPercentage: discount,
          imageUrl: 'https://picsum.photos/seed/'
              '${entry.title.replaceAll(RegExp(r'[^a-z0-9]'), '').toLowerCase()}/300/400',
          platform: entry.platform,
          isPsPlusBonus: rng.nextBool(),
        ),
      );
    }

    deals.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
    return deals;
  }

  /// Returns only the deals whose discount is >= [minDiscount].
  List<GameDeal> filterByDiscount(
    List<GameDeal> deals, {
    required int minDiscount,
  }) {
    return deals
        .where((d) => d.discountPercentage >= minDiscount)
        .toList()
      ..sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
  }

  static double _round2(double v) => (v * 100).round() / 100;
}

class _PoolEntry {
  final String title;
  final String platform;
  final double basePrice;

  const _PoolEntry(this.title, this.platform, this.basePrice);
}
