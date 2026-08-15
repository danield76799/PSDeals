import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_deal.dart';
import '../services/game_repository.dart';

/// Optional PS Store URL to scrape instead of the default deals page.
/// Set via the search field; `null` means "use the default deals page".
final sourceUrlProvider = StateProvider<String?>((ref) => null);

/// Async provider that loads the full (unfiltered) deal list once.
///
/// Reads [forceRefreshProvider]; when `true` the proxy cache is bypassed so a
/// manual refresh always returns fresh deals. Reads [sourceUrlProvider] to
/// optionally scrape a specific PS Store search/category URL.
final dealsProvider = FutureProvider.autoDispose<DealsResult>((ref) async {
  final repo = GameRepository();
  final force = ref.watch(forceRefreshProvider);
  final sourceUrl = ref.watch(sourceUrlProvider);
  return repo.fetchDeals(force: force, sourceUrl: sourceUrl);
});

/// When `true`, the next [dealsProvider] fetch bypasses the proxy cache.
/// Flip to `true` immediately before `ref.refresh(dealsProvider)`, then back
/// to `false` once the refresh future completes.
final forceRefreshProvider = StateProvider<bool>((ref) => false);

/// Holds the minimum discount threshold selected via slider / chips.
///
/// Defaults to 30% so the deals grid shows a useful number of results
/// (the PS Store "Deals" page only exposes ~10 games, of which few are
/// >=50%). Users can still raise it to 50%+ via the slider.
final minDiscountProvider = StateProvider<int>((ref) => 30);

/// Derives the visible deals by filtering the loaded list against the
/// current [minDiscountProvider] threshold.
final filteredDealsProvider = Provider<AsyncValue<List<GameDeal>>>((ref) {
  final dealsAsync = ref.watch(dealsProvider);
  final minDiscount = ref.watch(minDiscountProvider);
  return dealsAsync.whenData((result) {
    return GameRepository().filterByDiscount(result.deals, minDiscount: minDiscount);
  });
});
