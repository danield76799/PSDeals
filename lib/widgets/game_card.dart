import 'package:flutter/material.dart';

import '../models/game_deal.dart';
import '../services/game_repository.dart';
import '../theme/app_theme.dart';
import 'game_detail_sheet.dart';

/// A single game deal tile used inside the grid.
class GameCard extends StatelessWidget {
  final GameDeal deal;

  const GameCard({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => GameDetailSheet(deal: deal),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover artwork ──
            Expanded(
              flex: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    deal.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.surfaceAlt,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('[ImgError] ${deal.imageUrl} -> $error');
                      return Container(
                        color: AppTheme.surfaceAlt,
                        child: const Center(
                          child: Icon(
                            Icons.videogame_asset_rounded,
                            color: AppTheme.onSurfaceMuted,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  // Discount badge (top-left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.discountGreen,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '-${deal.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  // PS Plus indicator (top-right)
                  if (deal.isPsPlusBonus)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.psPlus,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'PS+',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ── Info section ──
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Platform tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        deal.platform,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppTheme.accentLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title (max 2 lines)
                    Expanded(
                      child: Text(
                        deal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // TEMP DEBUG: show image URL so we can see what loads
                    Text(
                      deal.imageUrl.isEmpty
                          ? '[NO IMG URL]'
                          : (deal.imageUrl.length > 42
                              ? '${deal.imageUrl.substring(0, 42)}…'
                              : deal.imageUrl),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Prices
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (deal.discountedPrice > 0) ...[
                          Flexible(
                            child: Text(
                              '${GameRepository.currencySymbol}${deal.originalPrice.toStringAsFixed(2)}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.onSurfaceMuted,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppTheme.onSurfaceMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            deal.discountedPrice > 0
                                ? '${GameRepository.currencySymbol}${deal.discountedPrice.toStringAsFixed(2)}'
                                : 'Gratis',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: deal.discountedPrice > 0 ? 16 : 15,
                              fontWeight: FontWeight.w800,
                              color: deal.discountedPrice > 0
                                  ? AppTheme.onSurface
                                  : AppTheme.discountGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
