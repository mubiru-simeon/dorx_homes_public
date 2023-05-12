import 'package:dorx/models/models.dart';
import 'package:hive/hive.dart';
import 'package:dorx/services/map_generation.dart';

class SearchHistoryDBServices {
  static const SEARCHHISTORYTEXT = "text";
  static const TIMESEARCHED = "time";

  bool saveSearchHistory(
    String history,
    Box box,
  ) {
    Map pp = box.get(DorxSettings.SEARCHHISTORY) ?? {};
    pp.addAll(
      {
        DateTime.now().millisecondsSinceEpoch.toString():
            MapGeneration().generateSearchHistoryMap(history),
      },
    );

    box.put(
      DorxSettings.SEARCHHISTORY,
      pp,
    );

    return true;
  }

  List<SearchHistory> getPreviousHistory(
    Box box,
  ) {
    List<SearchHistory> history0 = [];
    Map pp = box.get(DorxSettings.SEARCHHISTORY) ?? {};

    for (var item in pp.entries) {
      SearchHistory history = SearchHistory.fromMap(item.value);
      history0.add(history);
    }

    return history0;
  }

  deleteSpecificHistory(String id, Box box) async {
    box.delete(id);
  }

  clearTable(Box box) async {
    box.clear();
  }
}
