import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/play_session.dart';

const String sessionBoxName = 'sessionRecords';

class SessionNotifier extends Notifier<PlaySession?> {
  late final Box<PlaySession> _box;

  @override
  PlaySession? build() {
    _box = Hive.box<PlaySession>(sessionBoxName);
    
    // Find the first active session if one exists
    try {
      return _box.values.firstWhere((session) => session.isActive);
    } catch (e) {
      return null; // No active session
    }
  }

  Future<void> startSession(String location) async {
    // If there's already an active session, we might want to end it first
    if (state != null) {
      await endSession();
    }

    final newSession = PlaySession(
      id: const Uuid().v4(),
      date: DateTime.now(),
      location: location,
      isActive: true,
    );

    await _box.put(newSession.id, newSession);
    state = newSession;
  }

  Future<void> endSession() async {
    if (state != null) {
      state!.isActive = false;
      await state!.save(); // HiveObject.save()
      state = null;
    }
  }

  Future<void> addMatchToSession(String matchId) async {
    if (state != null) {
      state!.matchIds.add(matchId);
      await state!.save();
      // Trigger a rebuild by assigning a copy or just a new reference (since we modified the list)
      // For Hive objects, state = state isn't always enough to trigger riverpod rebuild if the reference is same,
      // but in this case, the session itself is just active/inactive, we probably don't need UI rebuild on match add.
      // But to be safe:
      state = state!.copyWith(matchIds: List.from(state!.matchIds));
    }
  }
}

final activeSessionProvider = NotifierProvider<SessionNotifier, PlaySession?>(SessionNotifier.new);
