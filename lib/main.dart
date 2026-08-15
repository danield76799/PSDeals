import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'providers/deal_providers.dart';
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

class DealsHomePage extends ConsumerWidget {
  const DealsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceUrl = ref.watch(sourceUrlProvider);
    final controller = TextEditingController(text: sourceUrl ?? '');
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
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppTheme.onSurfaceMuted),
                    tooltip: 'Ververs deals',
                    onPressed: () async {
                      // Bypass the proxy cache so we get fresh deals, then refresh.
                      ref.read(forceRefreshProvider.notifier).state = true;
                      try {
                        ref.invalidate(dealsProvider);
                        await ref.read(dealsProvider.future);
                      } finally {
                        ref.read(forceRefreshProvider.notifier).state = false;
                      }
                    },
                  ),
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
            // ── Search bar (scrape any PS Store URL) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Plak een PS Store URL (categorie/zoekterm)',
                        hintStyle:
                            const TextStyle(color: AppTheme.onSurfaceMuted),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppTheme.onSurfaceMuted, size: 20),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      style: const TextStyle(color: AppTheme.onSurface, fontSize: 13),
                      onSubmitted: (value) {
                        _applySearch(ref, value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.accent),
                    tooltip: 'Zoek',
                    onPressed: () => _applySearch(ref, controller.text),
                  ),
                  if (sourceUrl != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppTheme.onSurfaceMuted),
                      tooltip: 'Terug naar deals',
                      onPressed: () {
                        ref.read(sourceUrlProvider.notifier).state = null;
                        ref.invalidate(dealsProvider);
                      },
                    ),
                ],
              ),
            ),
            // ── Scrollable grid ──
            const Expanded(child: DealsGrid()),
          ],
        ),
      ),
    );
  }

  void _applySearch(WidgetRef ref, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    ref.read(sourceUrlProvider.notifier).state = trimmed;
    ref.invalidate(dealsProvider);
  }
}
