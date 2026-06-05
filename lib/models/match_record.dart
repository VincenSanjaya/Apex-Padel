import 'package:hive/hive.dart';

part 'match_record.g.dart';

@HiveType(typeId: 0)
enum MatchResult {
  @HiveField(0)
  win,
  @HiveField(1)
  loss,
  @HiveField(2)
  draw,
}

@HiveType(typeId: 1)
enum ScoringFormat {
  @HiveField(0)
  traditional,
  @HiveField(1)
  points,
}

@HiveType(typeId: 2)
class MatchRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final String? partnerName;

  @HiveField(4)
  final MatchResult result;

  @HiveField(5)
  final ScoringFormat scoringFormat;

  @HiveField(6)
  final String scoreData;

  @HiveField(7)
  final double ratingChange;

  MatchRecord({
    required this.id,
    required this.date,
    required this.location,
    this.partnerName,
    required this.result,
    required this.scoringFormat,
    required this.scoreData,
    required this.ratingChange,
  });

  MatchRecord copyWith({
    String? id,
    DateTime? date,
    String? location,
    String? partnerName,
    MatchResult? result,
    ScoringFormat? scoringFormat,
    String? scoreData,
    double? ratingChange,
  }) {
    return MatchRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      location: location ?? this.location,
      partnerName: partnerName ?? this.partnerName,
      result: result ?? this.result,
      scoringFormat: scoringFormat ?? this.scoringFormat,
      scoreData: scoreData ?? this.scoreData,
      ratingChange: ratingChange ?? this.ratingChange,
    );
  }
}
