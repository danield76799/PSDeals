import 'package:flutter/material.dart';

import '../models/game_deal.dart';
import '../services/game_repository.dart';
import '../theme/app_theme.dart';

/// Bottom-sheet showing extended info for a single [GameDeal].
///
/// Opened when a [GameCard] is tapped. Shows the cover, all price details,
/// discount, savings, platform and PS+ status.
class GameDetailSheet extends StatelessWidget {
  final GameDeal deal;

  const GameDetailSheet({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    final symbol = GameRepository.currencySymbol;

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.onSurfaceMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: deal.imageUrl.isEmpty
                      ? Container(
                          color: AppTheme.surfaceAlt,
                          child: const Center(
                            child: Icon(
                              Icons.videogame_asset_rounded,
                              color: AppTheme.onSurfaceMuted,
                              size: 56,
                            ),
                          ),
                        )
                      : Image.network(
                          deal.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppTheme.surfaceAlt,
                            child: const Center(
                              child: Icon(
                                Icons.videogame_asset_rounded,
                                color: AppTheme.onSurfaceMuted,
                                size: 56,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              // Title
              Text(
                deal.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              // Badges row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: deal.platform,
                    color: AppTheme.accentLight,
                  ),
                  _InfoChip(
                    label: '-${deal.discountPercentage}%',
                    color: AppTheme.discountGreen,
                    textColor: Colors.black,
                  ),
                  if (deal.isPsPlusBonus)
                    _InfoChip(
                      label: 'PS+ Bonus',
                      color: AppTheme.psPlus,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Price block
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _PriceRow(
                      label: 'Originele prijs',
                      value: deal.discountedPrice > 0
                          ? '$symbol${deal.originalPrice.toStringAsFixed(2)}'
                          : '—',
                      strikethrough: deal.discountedPrice > 0,
                    ),
                    const SizedBox(height: 8),
                    _PriceRow(
                      label: 'Nu',
                      value: deal.discountedPrice > 0
                          ? '$symbol${deal.discountedPrice.toStringAsFixed(2)}'
                          : 'Gratis',
                      highlight: true,
                    ),
                    const Divider(height: 20, color: AppTheme.divider),
                    _PriceRow(
                      label: 'Je bespaart',
                      value: deal.discountedPrice > 0
                          ? '$symbol${deal.savings.toStringAsFixed(2)}'
                          : '$symbol${deal.originalPrice.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Korting van ${deal.discountPercentage}% op ${deal.platform}.'
                '${deal.isPsPlusBonus ? ' Extra voordeel voor PlayStation Plus-leden.' : ''}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Sluiten'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const _InfoChip({required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strikethrough;
  final bool highlight;

  const _PriceRow({
    required this.label,
    required this.value,
    this.strikethrough = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: highlight ? AppTheme.onSurface : AppTheme.onSurfaceMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 22 : 16,
            fontWeight: FontWeight.w800,
            color: highlight ? AppTheme.onSurface : AppTheme.onSurfaceMuted,
            decoration:
                strikethrough ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: AppTheme.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}
