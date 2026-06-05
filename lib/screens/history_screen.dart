import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/match_provider.dart';
import '../models/match_record.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchProvider);
    final sortedMatches = List<MatchRecord>.from(matches)
      ..sort((a, b) => b.date.compareTo(a.date)); // Descending order

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERFORMANCE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'Match History',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.outline),
                  )
                ],
              ),
            ),
          ),
          if (sortedMatches.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No matches found.\nLog a match to see history.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                    child: _buildMatchCard(context, sortedMatches[index]),
                  );
                },
                childCount: sortedMatches.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)), // Bottom padding for nav bar
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
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDsbuVdigqkK6QAziMaIsphDpNPwvqvbqGrnpYViciAtxVf2-X6a_FGxEa_1VBl_VMjI-Q3_qSmpFszp-3RkS5SDcbYRGMBJ6m0A07nQfSGEPrSl9NZ60AhFflF079GAt1m18sSZQY0ccXnIopQdChKKXg-2RgNcTwMCkDbIyKdeKsxHnS3GQQIQIgXc4idKRO4PmfgO542SOd99ScC0-9wcM6cpRODbctGRyVtoVYWv4olS4rg2wNqqm_AJxKLPVabOzJx2Y2SyII2'),
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

  String _formatDate(DateTime date) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  Widget _buildMatchCard(BuildContext context, MatchRecord record) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Determine colors based on result
    Color mainColor;
    Color bgColor;
    String resultText;
    String ratingText;
    bool isWin = record.result == MatchResult.win;
    bool isLoss = record.result == MatchResult.loss;

    if (isWin) {
      mainColor = colorScheme.primary;
      bgColor = colorScheme.primary.withValues(alpha: 0.1);
      resultText = 'W';
      ratingText = 'Rating Up';
    } else if (isLoss) {
      mainColor = colorScheme.error;
      bgColor = colorScheme.errorContainer.withValues(alpha: 0.2);
      resultText = 'L';
      ratingText = 'Rating Down';
    } else {
      mainColor = colorScheme.outline;
      bgColor = colorScheme.surfaceContainer;
      resultText = 'D';
      ratingText = 'No Change';
    }

    final String ratingChangeStr = record.ratingChange > 0 
      ? '+${record.ratingChange.toStringAsFixed(2)}' 
      : record.ratingChange.toStringAsFixed(2);

    List<String> scoreParts = record.scoreData.split(',');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: isWin ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.1), blurRadius: 15)] : [],
      ),
      child: Column(
        children: [
          // Top Row: Info + Rating Change
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: isWin ? mainColor : colorScheme.outline),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(record.date),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.location,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  if (record.partnerName != null && record.partnerName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'w/ ${record.partnerName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: mainColor.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      ratingChangeStr,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: mainColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ratingText.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: mainColor,
                      fontSize: 10,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Bottom Row: Score + Vertical Line + Result Indicator
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FINAL SCORE', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Row(
                      children: scoreParts.map((score) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          score.trim(),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontSize: 28,
                            color: isWin ? mainColor : Theme.of(context).colorScheme.onSurface,
                            shadows: isWin ? [Shadow(color: mainColor.withValues(alpha: 0.4), blurRadius: 10)] : [],
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isWin ? mainColor : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isWin ? [BoxShadow(color: mainColor.withValues(alpha: 0.5), blurRadius: 8)] : [],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('RESULT', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(
                      resultText,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isLoss ? Theme.of(context).colorScheme.onSurfaceVariant : mainColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
