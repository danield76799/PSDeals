import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'widgets/deals_grid.dart';
import 'widgets/discount_filter_header.dart';
import 'widgets/shimmer_logo.dart';

void main() {
  runApp(const ProviderScope(child: PlayStationDealsApp()));
}

class PlayStationDealsApp extends StatelessWidget {
  const PlayStationDealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PS Store Deals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DealsHomePage(),
    );
  }
}

class DealsHomePage extends StatelessWidget {
  const DealsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top app bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const ShimmerLogo(size: 44),
                  const SizedBox(width: 12),
                  const Text(
                    'PlayStation Deals',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_none_rounded,
                      color: AppTheme.onSurfaceMuted),
                ],
              ),
            ),
            // ── Sticky filter header (top card) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: const DiscountFilterHeader(),
            ),
            // ── Scrollable grid ──
            const Expanded(child: DealsGrid()),
          ],
        ),
      ),
    );
  }
}
