import 'package:flutter/foundation.dart';

class SearchHistoryService {
  static final SearchHistoryService _instance =
      SearchHistoryService._internal();
  factory SearchHistoryService() => _instance;
  SearchHistoryService._internal();

  final List<String> _history = [];
  final ValueNotifier<List<String>> historyNotifier =
      ValueNotifier<List<String>>([]);

  void addSearch(String query) {
    if (query.trim().isEmpty) return;

    // Remove if already exists to move to top
    _history.removeWhere(
      (item) => item.toLowerCase() == query.trim().toLowerCase(),
    );

    // Add to top
    _history.insert(0, query.trim());

    // Keep only last 5
    if (_history.length > 5) {
      _history.removeRange(5, _history.length);
    }

    historyNotifier.value = List.from(_history);
  }

  List<String> get history => List.unmodifiable(_history);

  void clearHistory() {
    _history.clear();
    historyNotifier.value = [];
  }
}
