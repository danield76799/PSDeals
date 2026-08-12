import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/deal_providers.dart';
import '../services/game_repository.dart';
import '../theme/app_theme.dart';

/// Sticky header card that drives the minimum-discount filter.
///
/// Combines a discrete [Slider] (snapped to the discount steps) with a row of
/// quick-select filter chips for fast access to common thresholds.
class DiscountFilterHeader extends ConsumerWidget {
  const DiscountFilterHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minDiscount = ref.watch(minDiscountProvider);
    final steps = GameRepository.discountSteps;
    final currentIndex = steps.indexOf(minDiscount).clamp(0, steps.length - 1);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surface, AppTheme.backgroundAlt],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_rounded, color: AppTheme.accentLight, size: 20),
              const SizedBox(width: 8),
              Text(
                'Toon deals met $minDiscount%+ korting',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      color: AppTheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Slider(
            value: currentIndex.toDouble(),
            min: 0,
            max: (steps.length - 1).toDouble(),
            divisions: steps.length - 1,
            label: '${steps[currentIndex]}%',
            onChanged: (value) {
              ref.read(minDiscountProvider.notifier).state = steps[value.round()];
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: steps
                  .map(
                    (s) => Text(
                      '$s%',
                      style: TextStyle(
                        fontSize: 11,
                        color: s == minDiscount
                            ? AppTheme.accentLight
                            : AppTheme.onSurfaceMuted,
                        fontWeight:
                            s == minDiscount ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [50, 70, 90].map((threshold) {
              final selected = minDiscount == threshold;
              return ChoiceChip(
                label: Text('$threshold%+'),
                selected: selected,
                onSelected: (_) =>
                    ref.read(minDiscountProvider.notifier).state = threshold,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
