import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/deal_providers.dart';
import '../theme/app_theme.dart';
import 'game_card.dart';

/// Empty-state widget shown when no deals match the current threshold.
class EmptyDealsView extends ConsumerWidget {
  const EmptyDealsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minDiscount = ref.watch(minDiscountProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.onSurfaceMuted,
            ),
            const SizedBox(height: 20),
            Text(
              'Geen deals gevonden voor $minDiscount%+ korting',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verlaag de kortingsdrempel om meer aanbiedingen te zien.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceMuted),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(minDiscountProvider.notifier).state = 50,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset naar 50%'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsive 2-column grid of [GameCard] driven by [filteredDealsProvider].
class DealsGrid extends ConsumerWidget {
  const DealsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredDealsProvider);

    return filteredAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentLight),
      ),
      error: (e, _) => Center(
        child: Text(
          'Failed to load deals.\n$e',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.onSurfaceMuted),
        ),
      ),
      data: (deals) {
        if (deals.isEmpty) return const EmptyDealsView();

        final crossAxisCount =
            MediaQuery.of(context).size.width >= 720 ? 4 : 2;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.66,
          ),
          itemCount: deals.length,
          itemBuilder: (context, index) => GameCard(deal: deals[index]),
        );
      },
    );
  }
}
