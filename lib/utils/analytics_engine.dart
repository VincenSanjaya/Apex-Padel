import '../models/match_record.dart';

class LifetimeStats {
  final double winRate;
  final int totalMatches;
  final int wins;
  final int draws;
  final int losses;

  LifetimeStats({
    required this.winRate,
    required this.totalMatches,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  String get wdlString => '$wins-$draws-$losses';
}

class PartnerStat {
  final String name;
  final int matches;
  final int wins;
  
  PartnerStat(this.name, this.matches, this.wins);
  
  double get winRate => matches == 0 ? 0 : wins / matches;
}

class PartnerAnalytics {
  final PartnerStat? bestPartner;
  final PartnerStat? needsSynergy;
  final PartnerStat? mostFrequent;

  PartnerAnalytics({
    this.bestPartner,
    this.needsSynergy,
    this.mostFrequent,
  });
}

class LocationStat {
  final String name;
  final int count;

  LocationStat(this.name, this.count);
}

class FormatMastery {
  final double traditionalWinRate;
  final int traditionalMatches;
  final double pointsWinRate;
  final int pointsMatches;

  FormatMastery({
    required this.traditionalWinRate,
    required this.traditionalMatches,
    required this.pointsWinRate,
    required this.pointsMatches,
  });
}

class AnalyticsEngine {
  final List<MatchRecord> matches;

  AnalyticsEngine(this.matches);

  LifetimeStats getLifetimeStats() {
    int wins = 0;
    int draws = 0;
    int losses = 0;

    for (var match in matches) {
      if (match.result == MatchResult.win) wins++;
      else if (match.result == MatchResult.loss) losses++;
      else if (match.result == MatchResult.draw) draws++;
    }

    final total = matches.length;
    final winRate = total == 0 ? 0.0 : (wins / total) * 100;

    return LifetimeStats(
      winRate: winRate,
      totalMatches: total,
      wins: wins,
      draws: draws,
      losses: losses,
    );
  }

  PartnerAnalytics getPartnerAnalytics() {
    final Map<String, List<MatchRecord>> partnerMap = {};

    for (var match in matches) {
      if (match.partnerName != null && match.partnerName!.trim().isNotEmpty) {
        final name = match.partnerName!.trim();
        partnerMap.putIfAbsent(name, () => []).add(match);
      }
    }

    if (partnerMap.isEmpty) {
      return PartnerAnalytics();
    }

    final List<PartnerStat> stats = partnerMap.entries.map((e) {
      final w = e.value.where((m) => m.result == MatchResult.win).length;
      return PartnerStat(e.key, e.value.length, w);
    }).toList();

    // Most frequent
    stats.sort((a, b) => b.matches.compareTo(a.matches));
    final mostFrequent = stats.first;

    // Filter for min 3 matches for chemistry
    final qualified = stats.where((s) => s.matches >= 3).toList();
    PartnerStat? best;
    PartnerStat? synergy;

    if (qualified.isNotEmpty) {
      qualified.sort((a, b) => b.winRate.compareTo(a.winRate));
      best = qualified.first;
      
      qualified.sort((a, b) => a.winRate.compareTo(b.winRate));
      synergy = qualified.first;
    }

    return PartnerAnalytics(
      bestPartner: best,
      needsSynergy: synergy,
      mostFrequent: mostFrequent,
    );
  }

  List<LocationStat> getTopLocations({int limit = 3}) {
    final Map<String, int> locMap = {};

    for (var match in matches) {
      final loc = match.location.trim();
      if (loc.isNotEmpty) {
        locMap[loc] = (locMap[loc] ?? 0) + 1;
      }
    }

    final stats = locMap.entries.map((e) => LocationStat(e.key, e.value)).toList();
    stats.sort((a, b) => b.count.compareTo(a.count));

    return stats.take(limit).toList();
  }

  FormatMastery getFormatMastery() {
    int tradMatches = 0;
    int tradWins = 0;
    int pointMatches = 0;
    int pointWins = 0;

    for (var match in matches) {
      if (match.scoringFormat == ScoringFormat.traditional) {
        tradMatches++;
        if (match.result == MatchResult.win) tradWins++;
      } else if (match.scoringFormat == ScoringFormat.points) {
        pointMatches++;
        if (match.result == MatchResult.win) pointWins++;
      }
    }

    return FormatMastery(
      traditionalWinRate: tradMatches == 0 ? 0.0 : (tradWins / tradMatches) * 100,
      traditionalMatches: tradMatches,
      pointsWinRate: pointMatches == 0 ? 0.0 : (pointWins / pointMatches) * 100,
      pointsMatches: pointMatches,
    );
  }
}
