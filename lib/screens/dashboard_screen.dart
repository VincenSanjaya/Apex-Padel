import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/match_provider.dart';
import '../providers/nav_provider.dart';
import '../models/match_record.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRating = ref.watch(currentRatingProvider);
    final matches = ref.watch(matchProvider);

    // Calculate Wins/Losses
    final wins = matches.where((m) => m.result == MatchResult.win).length;
    final losses = matches.where((m) => m.result == MatchResult.loss).length;

    // Build Chart Data (Last 10 matches)
    final chartSpots = _buildChartSpots(matches);

    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroRating(context, currentRating),
                const SizedBox(height: 40),
                _buildRatingTrendCard(context, currentRating, chartSpots),
                const SizedBox(height: 16),
                _buildBentoStats(context, wins, losses),
                const SizedBox(height: 40),
                _buildLogMatchButton(context, ref),
                const SizedBox(height: 100), // Bottom padding for nav bar
              ],
            ),
          ),
        )
      ],
    );
  }

  List<FlSpot> _buildChartSpots(List<MatchRecord> matches) {
    if (matches.isEmpty) {
      return [const FlSpot(0, 2.0)]; // Base rating
    }

    final sorted = List<MatchRecord>.from(matches)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate historical ratings
    double runningRating = 2.0;
    List<double> history = [runningRating];

    for (var m in sorted) {
      runningRating += m.ratingChange;
      if (runningRating < 0.0) runningRating = 0.0;
      if (runningRating > 10.0) runningRating = 10.0;
      history.add(runningRating);
    }

    // Get last 10 points (or fewer)
    final last10 = history.reversed.take(10).toList().reversed.toList();
    
    List<FlSpot> spots = [];
    for (int i = 0; i < last10.length; i++) {
      spots.add(FlSpot(i.toDouble(), last10[i]));
    }
    return spots;
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
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
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAfx3EyoDjA79PbSoYpgZFqJS_652zL8GziUzoVGh3XNKIDwvUyB2JWHxXZZ1tiR7xme7BiU4jA4dSkpBjlBWvWRWvtSpW3vcYpGR9KIGQXMMpRcB_-tVNlricyCtnW7yYssJiEaBmftyV2mKGMg9qBUHRuVol5KN0tu3jT31gmuoiJnB97euGMesw7N1xS4qdJCw_MTOJH5maXMIPf58FIxx84rrTDYcRn6IdVTR80jSVljCJviDDXU10aDXda-1hfPLNECUFJl67Y'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'APEX PADEL',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.primary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroRating(BuildContext context, double currentRating) {
    final colorScheme = Theme.of(context).colorScheme;
    final String level = currentRating >= 6.0 ? "Advanced" : (currentRating >= 4.0 ? "Intermediate" : "Beginner");

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            Text(
              currentRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 120,
                height: 1.0,
                color: colorScheme.primary,
                shadows: [
                  Shadow(
                    color: colorScheme.primary.withOpacity(0.6),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'CURRENT LEVEL: ${level.toUpperCase()}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingTrendCard(BuildContext context, double currentRating, List<FlSpot> spots) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rating Trend', style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                  Text('LAST 10 MATCHES', style: textTheme.labelLarge?.copyWith(fontSize: 12, color: colorScheme.outline)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('+0.4', style: textTheme.displaySmall?.copyWith(color: colorScheme.primary, height: 1.0)),
                  Text('THIS MONTH', style: textTheme.labelLarge?.copyWith(fontSize: 10, color: colorScheme.outline)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: spots.isEmpty ? 1 : (spots.length - 1).toDouble(),
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: spot.x == barData.spots.last.x ? 6 : 4,
                          color: colorScheme.primary,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.primary.withOpacity(0.3),
                          colorScheme.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoStats(BuildContext context, int wins, int losses) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, Icons.emoji_events, wins.toString(), 'WINS')),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, Icons.sports_tennis, losses.toString(), 'LOSSES')),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: colorScheme.primary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, height: 1.0)),
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12, color: colorScheme.outline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogMatchButton(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () {
          ref.read(bottomNavIndexProvider.notifier).setIndex(1);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, size: 28),
            const SizedBox(width: 12),
            Text(
              'LOG MATCH',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
