import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdventureState {
  final List<int> usedIdeaIds;
  final int dailyViewCount;
  final String lastViewDate;

  AdventureState({
    required this.usedIdeaIds,
    required this.dailyViewCount,
    required this.lastViewDate,
  });

  factory AdventureState.initial() =>
      AdventureState(usedIdeaIds: [], dailyViewCount: 0, lastViewDate: '');

  factory AdventureState.fromJson(Map<String, dynamic> json) => AdventureState(
    usedIdeaIds: List<int>.from(json['usedIdeaIds']),
    dailyViewCount: json['dailyViewCount'],
    lastViewDate: json['lastViewDate'],
  );

  Map<String, dynamic> toJson() => {
    'usedIdeaIds': usedIdeaIds,
    'dailyViewCount': dailyViewCount,
    'lastViewDate': lastViewDate,
  };

  AdventureState copyWith({
    List<int>? usedIdeaIds,
    int? dailyViewCount,
    String? lastViewDate,
  }) {
    return AdventureState(
      usedIdeaIds: usedIdeaIds ?? this.usedIdeaIds,
      dailyViewCount: dailyViewCount ?? this.dailyViewCount,
      lastViewDate: lastViewDate ?? this.lastViewDate,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adventure_state', jsonEncode(toJson()));
  }

  static Future<AdventureState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('adventure_state');
    if (jsonString == null) return AdventureState.initial();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return AdventureState.fromJson(json);
  }

  bool canViewToday() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (lastViewDate != today) return true;
    return dailyViewCount < 2;
  }

  AdventureState updateAfterView() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    int newCount = dailyViewCount;
    String newDate = lastViewDate;

    if (lastViewDate != today) {
      newCount = 1;
      newDate = today;
    } else {
      newCount++;
    }

    return copyWith(dailyViewCount: newCount, lastViewDate: newDate);
  }

  bool hasSeenAllIdeas() => usedIdeaIds.length >= 80;
}
