import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

/// Manages the active tab index of the BottomNavigationBar globally.
final bottomNavIndexProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);
