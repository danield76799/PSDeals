import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_deal.dart';
import '../services/game_repository.dart';

/// Async provider that loads the full (unfiltered) deal list once.
final dealsProvider = FutureProvider<List<GameDeal>>((ref) async {
  final repo = GameRepository();
  return repo.fetchDeals();
});

/// Holds the minimum discount threshold selected via slider / chips.
///
/// Defaults to 50% (the lowest step) so every deal is visible initially.
final minDiscountProvider = StateProvider<int>((ref) => 50);

/// Derives the visible deals by filtering the loaded list against the
/// current [minDiscountProvider] threshold.
final filteredDealsProvider = Provider<AsyncValue<List<GameDeal>>>((ref) {
  final dealsAsync = ref.watch(dealsProvider);
  final minDiscount = ref.watch(minDiscountProvider);
  return dealsAsync.whenData((deals) {
    return GameRepository().filterByDiscount(deals, minDiscount: minDiscount);
  });
});
