import 'package:hive/hive.dart';

part 'play_session.g.dart';

@HiveType(typeId: 3)
class PlaySession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String location;

  @HiveField(3)
  bool isActive;

  @HiveField(4)
  List<String> matchIds;

  PlaySession({
    required this.id,
    required this.date,
    required this.location,
    this.isActive = true,
    List<String>? matchIds,
  }) : matchIds = matchIds ?? [];

  PlaySession copyWith({
    String? id,
    DateTime? date,
    String? location,
    bool? isActive,
    List<String>? matchIds,
  }) {
    return PlaySession(
      id: id ?? this.id,
      date: date ?? this.date,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      matchIds: matchIds ?? this.matchIds,
    );
  }
}
