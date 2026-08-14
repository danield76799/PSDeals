import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_deal.dart';
import '../services/game_repository.dart';

/// Async provider that loads the full (unfiltered) deal list once.
///
/// Reads [forceRefreshProvider]; when `true` the proxy cache is bypassed so a
/// manual refresh always returns fresh deals.
final dealsProvider = FutureProvider.autoDispose<DealsResult>((ref) async {
  final repo = GameRepository();
  final force = ref.watch(forceRefreshProvider);
  return repo.fetchDeals(force: force);
});

/// When `true`, the next [dealsProvider] fetch bypasses the proxy cache.
/// Flip to `true` immediately before `ref.refresh(dealsProvider)`, then back
/// to `false` once the refresh future completes.
final forceRefreshProvider = StateProvider<bool>((ref) => false);

/// Holds the minimum discount threshold selected via slider / chips.
///
/// Defaults to 50% (the lowest step) so every deal is visible initially.
final minDiscountProvider = StateProvider<int>((ref) => 50);

/// Derives the visible deals by filtering the loaded list against the
/// current [minDiscountProvider] threshold.
final filteredDealsProvider = Provider<AsyncValue<List<GameDeal>>>((ref) {
  final dealsAsync = ref.watch(dealsProvider);
  final minDiscount = ref.watch(minDiscountProvider);
  return dealsAsync.whenData((result) {
    return GameRepository().filterByDiscount(result.deals, minDiscount: minDiscount);
  });
});
