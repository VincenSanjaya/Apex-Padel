import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/match_record.dart';
import '../utils/rating_calculator.dart';

const String matchBoxName = 'matchRecords';

class MatchNotifier extends Notifier<List<MatchRecord>> {
  late final Box<MatchRecord> _box;

  @override
  List<MatchRecord> build() {
    _box = Hive.box<MatchRecord>(matchBoxName);
    return _box.values.toList();
  }

  Future<void> addMatch({
    required DateTime date,
    required String location,
    String? partnerName,
    required ScoringFormat scoringFormat,
    required String scoreData,
  }) async {
    final ratingChange = RatingCalculator.calculateRatingChange(scoringFormat, scoreData);
    final result = RatingCalculator.deriveResult(ratingChange);

    final record = MatchRecord(
      id: const Uuid().v4(),
      date: date,
      location: location,
      partnerName: partnerName,
      result: result,
      scoringFormat: scoringFormat,
      scoreData: scoreData,
      ratingChange: ratingChange,
    );

    await _box.put(record.id, record);
    state = _box.values.toList();
  }

  Future<void> deleteMatch(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }
}

/// Provider for the list of matches
final matchProvider = NotifierProvider<MatchNotifier, List<MatchRecord>>(MatchNotifier.new);

/// Derived provider for the current rating based on all matches
final currentRatingProvider = Provider<double>((ref) {
  final matches = ref.watch(matchProvider);
  
  double rating = RatingCalculator.baseRating;
  
  final sortedMatches = List<MatchRecord>.from(matches)..sort((a, b) => a.date.compareTo(b.date));

  for (final match in sortedMatches) {
    rating += match.ratingChange;
  }

  if (rating < RatingCalculator.minRating) rating = RatingCalculator.minRating;
  else if (rating > RatingCalculator.maxRating) rating = RatingCalculator.maxRating;

  return double.parse(rating.toStringAsFixed(1));
});
