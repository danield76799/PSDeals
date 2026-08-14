import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/game_deal.dart';

/// Provides access to PlayStation deal data.
///
/// SOURCE STRATEGY
/// ---------------
/// Live deals are scraped from the official PlayStation Store (NL) by a small
/// proxy running on the user's VM (see server.js). [fetchDeals] calls that
/// proxy over HTTP and maps the JSON into [GameDeal].
///
/// If the proxy is unreachable (offline / VM down), we fall back to a curated
/// pool of real PS titles so the app is always usable.
class GameRepository {
  /// Base URL of the deals proxy. Override with --dart-define=PROXY_URL=...
  static const String proxyUrl =
      String.fromEnvironment('PROXY_URL', defaultValue: 'http://13.140.136.172:8080');

  /// Discrete discount thresholds offered by the slider / quick chips.
  static const List<int> discountSteps = [50, 60, 70, 80, 90, 100];

  /// Currency symbol used across the UI (Euro).
  static const String currencySymbol = '€';

  /// Curated pool of real PlayStation titles — used as an offline fallback.
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
    _PoolEntry('Hitman World of Assassination', 'PS5', 39.99, isFree: true),
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

  /// Fetches the current deal list.
  ///
  /// Tries the live proxy first; on any failure returns the offline fallback.
  /// [force] bypasses the proxy's 10-minute cache (used by refresh actions).
  Future<List<GameDeal>> fetchDeals({
    String? platform,
    int minDiscount = 0,
    bool force = false,
  }) async {
    try {
      final query = <String, String>{};
      if (platform != null) query['platform'] = platform;
      if (minDiscount > 0) query['minDiscount'] = minDiscount.toString();
      if (force) query['force'] = '1';
      final uri = Uri.parse(proxyUrl).replace(path: '/deals', queryParameters: query);
      final resp = await http
          .get(uri)
          .timeout(const Duration(seconds: 35));
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final dealsJson = (json['deals'] as List?) ?? [];
        final deals = dealsJson
            .map((e) => GameDeal.fromJson(e as Map<String, dynamic>))
            .toList();
        if (deals.isNotEmpty) return deals;
      }
    } catch (e) {
      // Fall through to offline fallback.
    }
    return _fallbackDeals();
  }

  /// Offline fallback: a daily-varying slice of the curated pool.
  List<GameDeal> _fallbackDeals() {
    final now = DateTime.now();
    final daySeed = now.year * 1000 + now.month * 50 + now.day;
    final rng = Random(daySeed);
    final pool = List<_PoolEntry>.from(_pool)..shuffle(rng);
    final count = 18 + rng.nextInt(7);
    final deals = <GameDeal>[];
    for (var i = 0; i < count && i < pool.length; i++) {
      final entry = pool[i];
      final discount = entry.isFree
          ? 100
          : discountSteps[rng.nextInt(discountSteps.length)];
      final original = entry.basePrice;
      final discounted =
          entry.isFree ? 0.0 : _round2(original * (1 - discount / 100));
      deals.add(
        GameDeal(
          id: 'd${daySeed}_$i',
          title: entry.title,
          originalPrice: original,
          discountedPrice: discounted,
          discountPercentage: discount,
          // No external image for offline fallback — the card shows the
          // game icon instead of a broken/blocked remote image.
          imageUrl: '',
          platform: entry.platform,
          isPsPlusBonus: entry.isFree || rng.nextBool(),
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
  final bool isFree;

  const _PoolEntry(this.title, this.platform, this.basePrice, {this.isFree = false});
}
