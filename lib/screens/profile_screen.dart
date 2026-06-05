import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/match_provider.dart';
import '../utils/analytics_engine.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchProvider);
    final currentRating = ref.watch(currentRatingProvider);
    final engine = AnalyticsEngine(matches);

    final lifetime = engine.getLifetimeStats();
    final partnerAnalytics = engine.getPartnerAnalytics();
    final topLocations = engine.getTopLocations();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 120, bottom: 40),
              child: _buildHeroSection(context, currentRating),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickStats(context, lifetime),
                const SizedBox(height: 40),
                _buildSectionTitle(context, 'CHEMISTRY REPORT'),
                _buildChemistryReport(context, partnerAnalytics),
                const SizedBox(height: 40),
                _buildSectionTitle(context, 'HOME COURTS'),
                _buildHomeCourts(context, topLocations),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD72Ya0oLhfm1XMdqriPd3pza_k-VKpFaFTEzDpQs8LnKpCxKyF2VvP37mbUvd1J3IWRWO9Twld9onFqwb2-ILb9w28bz8eyZL4SY4vkP0tv-48xolsUfik24NGKysgj-RB8hTFgB98j2HASOE5FMEWWFwip4vyiip0PgrwD0p_ZpJwEW4yc9WvVvZGohI42DpxRcXfdOlEdNMmr4-fzTyt_UkDrbtZwd1xrTw9t3z0Xk2ryCsFX8g3kWgaMxRCx6vVZHPYk54wOAAl'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PADEL ELITE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, double rating) {
    String badge = 'BEGINNER';
    if (rating >= 3.0 && rating < 5.0) badge = 'INTERMEDIATE';
    else if (rating >= 5.0) badge = 'ADVANCED';

    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh, width: 4),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
            child: const CircleAvatar(
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA8qv8w1walvjNfUu0fvQd4t2hiGjQGUH6PFWe1I2U46Hi79zdLPdZZ6_m1OxENmtuMh2BlzUTTQE89Zfd8ZRn4I3-gz9j9CCe_mpyMtNlfiZ-oU7Ur2OZVD9TEVQVzQSSKIABVp9n2zYg3KOE-OgFQmQip4FxfdHOBbbCR_jRvLc39_uD0QA0CIRDDk3c0qRFSxnn38511s0hnubJM37h_DRr8ZT4Biti7L2ciHXdCbPv5uQoE_MQ7Y35h6z6NUJKPaV4SJ8dkLzFL'),
            ),
          ),
        ),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.oswald(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            height: 1.0,
            shadows: [
              Shadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 15,
              )
            ]
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            badge,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, LifetimeStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            context,
            '${stats.winRate.toStringAsFixed(0)}%',
            'WIN RATE',
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickStatCard(
            context,
            '${stats.totalMatches}',
            'TOTAL MATCHES',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickStatCard(
            context,
            stats.wdlString,
            'W/D/L RECORD',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(BuildContext context, String value, String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Theme.of(context).colorScheme.primary : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildChemistryReport(BuildContext context, PartnerAnalytics analytics) {
    return Column(
      children: [
        _buildChemistryRow(
          context,
          'Best Duo',
          analytics.bestPartner,
          Icons.stars,
          Theme.of(context).colorScheme.primary,
          trailingIcon: Icons.local_fire_department,
          fallbackMessage: 'Play 3+ matches with someone to unlock!',
        ),
        const SizedBox(height: 16),
        _buildChemistryRow(
          context,
          'Needs Synergy',
          analytics.needsSynergy,
          Icons.group_off,
          Theme.of(context).colorScheme.error,
          trailingIcon: null,
          fallbackMessage: 'No rivalries yet.',
        ),
      ],
    );
  }

  Widget _buildChemistryRow(BuildContext context, String type, PartnerStat? stat, IconData icon, Color color, {IconData? trailingIcon, required String fallbackMessage}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: trailingIcon != null ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)] : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 16),
                if (stat != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                        ),
                        Text(
                          '${(stat.winRate * 100).toStringAsFixed(0)}% Win Rate',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                        ),
                        Text(
                          fallbackMessage,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: color),
        ],
      ),
    );
  }

  Widget _buildHomeCourts(BuildContext context, List<LocationStat> locations) {
    if (locations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Center(child: Text('No location data yet.', style: Theme.of(context).textTheme.bodyMedium)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: locations.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          final isLast = index == locations.length - 1;
          
          Color numberColor = Theme.of(context).colorScheme.onSurfaceVariant;
          if (index == 0) numberColor = Theme.of(context).colorScheme.primary;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '0${index + 1}',
                          style: GoogleFonts.oswald(
                            fontSize: 20,
                            color: numberColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat.name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                                const SizedBox(width: 4),
                                Text(
                                  'FAVORITE COURT',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${stat.count} Matches',
                      style: GoogleFonts.oswald(
                        fontSize: 16,
                        color: index == 0 ? Theme.of(context).colorScheme.primary : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: Colors.white10),
            ],
          );
        }).toList(),
      ),
    );
  }
}
