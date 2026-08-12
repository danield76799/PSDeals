import '../models/game_deal.dart';

/// Provides access to PlayStation deal data.
///
/// In a real app this would hit the PlayStation Store API (or a third-party
/// deals aggregator). Here we serve a curated, realistic mock dataset of
/// European PS Store prices (EUR, VAT included) so the UI, filtering and
/// theming can be exercised end to end without network access.
class GameRepository {
  /// Discrete discount thresholds offered by the slider / quick chips.
  static const List<int> discountSteps = [50, 60, 70, 80, 90, 100];

  /// Currency symbol used across the UI (Euro).
  static const String currencySymbol = '€';

  /// Returns the full list of available deals (unfiltered).
  ///
  /// A small artificial delay simulates a network round-trip so loading
  /// states can be observed in the UI.
  Future<List<GameDeal>> fetchDeals() async {
    // await Future.delayed(const Duration(milliseconds: 300));
    return _mockDeals;
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

  static const List<GameDeal> _mockDeals = [
    GameDeal(
      id: 'g1',
      title: 'Marvel\'s Spider-Man 2',
      originalPrice: 79.99,
      discountedPrice: 39.99,
      discountPercentage: 50,
      imageUrl: 'https://picsum.photos/seed/spiderman2/300/400',
      platform: 'PS5',
      isPsPlusBonus: true,
    ),
    GameDeal(
      id: 'g2',
      title: 'Horizon Forbidden West',
      originalPrice: 69.99,
      discountedPrice: 27.99,
      discountPercentage: 60,
      imageUrl: 'https://picsum.photos/seed/horizonfw/300/400',
      platform: 'PS5',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g3',
      title: 'God of War Ragnarök',
      originalPrice: 79.99,
      discountedPrice: 23.99,
      discountPercentage: 70,
      imageUrl: 'https://picsum.photos/seed/gowragnarok/300/400',
      platform: 'PS5',
      isPsPlusBonus: true,
    ),
    GameDeal(
      id: 'g4',
      title: 'The Last of Us Part I',
      originalPrice: 79.99,
      discountedPrice: 15.99,
      discountPercentage: 80,
      imageUrl: 'https://picsum.photos/seed/tlou1/300/400',
      platform: 'PS5',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g5',
      title: 'Ghost of Tsushima Director\'s Cut',
      originalPrice: 69.99,
      discountedPrice: 6.99,
      discountPercentage: 90,
      imageUrl: 'https://picsum.photos/seed/ghosttsu/300/400',
      platform: 'PS5',
      isPsPlusBonus: true,
    ),
    GameDeal(
      id: 'g6',
      title: 'Ratchet & Clank: Rift Apart',
      originalPrice: 69.99,
      discountedPrice: 34.99,
      discountPercentage: 50,
      imageUrl: 'https://picsum.photos/seed/ratchet/300/400',
      platform: 'PS5',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g7',
      title: 'Elden Ring',
      originalPrice: 69.99,
      discountedPrice: 27.99,
      discountPercentage: 60,
      imageUrl: 'https://picsum.photos/seed/eldenring/300/400',
      platform: 'PS5',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g8',
      title: 'Demon\'s Souls',
      originalPrice: 79.99,
      discountedPrice: 19.99,
      discountPercentage: 75,
      imageUrl: 'https://picsum.photos/seed/demonsouls/300/400',
      platform: 'PS5',
      isPsPlusBonus: true,
    ),
    GameDeal(
      id: 'g9',
      title: 'Returnal',
      originalPrice: 79.99,
      discountedPrice: 15.99,
      discountPercentage: 80,
      imageUrl: 'https://picsum.photos/seed/returnal/300/400',
      platform: 'PS5',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g10',
      title: 'Death Stranding Director\'s Cut',
      originalPrice: 49.99,
      discountedPrice: 4.99,
      discountPercentage: 90,
      imageUrl: 'https://picsum.photos/seed/deathstranding/300/400',
      platform: 'PS5',
      isPsPlusBonus: true,
    ),
    GameDeal(
      id: 'g11',
      title: 'Bloodborne (PS4)',
      originalPrice: 19.99,
      discountedPrice: 9.99,
      discountPercentage: 50,
      imageUrl: 'https://picsum.photos/seed/bloodborne/300/400',
      platform: 'PS4',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g12',
      title: 'Persona 5 Royal',
      originalPrice: 59.99,
      discountedPrice: 17.99,
      discountPercentage: 70,
      imageUrl: 'https://picsum.photos/seed/persona5/300/400',
      platform: 'PS4',
      isPsPlusBonus: true,
    ),
    GameDeal(
      id: 'g13',
      title: 'Red Dead Redemption 2',
      originalPrice: 39.99,
      discountedPrice: 7.99,
      discountPercentage: 80,
      imageUrl: 'https://picsum.photos/seed/rdr2/300/400',
      platform: 'PS4',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g14',
      title: 'The Witcher 3: Wild Hunt Complete Edition',
      originalPrice: 39.99,
      discountedPrice: 3.99,
      discountPercentage: 90,
      imageUrl: 'https://picsum.photos/seed/witcher3/300/400',
      platform: 'PS4',
      isPsPlusBonus: true,
    ),
    GameDeal(
      id: 'g15',
      title: 'Cyberpunk 2077 Ultimate Edition',
      originalPrice: 59.99,
      discountedPrice: 11.99,
      discountPercentage: 80,
      imageUrl: 'https://picsum.photos/seed/cyberpunk/300/400',
      platform: 'PS5',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g16',
      title: 'Final Fantasy VII Rebirth',
      originalPrice: 79.99,
      discountedPrice: 31.99,
      discountPercentage: 60,
      imageUrl: 'https://picsum.photos/seed/ff7rebirth/300/400',
      platform: 'PS5',
      isPsPlusBonus: true,
    ),
    GameDeal(
      id: 'g17',
      title: 'Hogwarts Legacy',
      originalPrice: 69.99,
      discountedPrice: 17.49,
      discountPercentage: 75,
      imageUrl: 'https://picsum.photos/seed/hogwarts/300/400',
      platform: 'PS5',
      isPsPlusBonus: false,
    ),
    GameDeal(
      id: 'g18',
      title: 'Gran Turismo 7',
      originalPrice: 79.99,
      discountedPrice: 7.99,
      discountPercentage: 90,
      imageUrl: 'https://picsum.photos/seed/gt7/300/400',
      platform: 'PS5',
      isPsPlusBonus: true,
    ),
  ];
}
