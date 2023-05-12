import 'package:algolia/algolia.dart';

import '../constants/constants.dart';

class SearchServices {
  Future<List<AlgoliaObjectSnapshot>> search(
    String searchText,
    String indexToQuery,
  ) async {
    if (searchText.trim().isNotEmpty) {
      Algolia algolia = Algolia.init(
        applicationId: algoliaAppID,
        apiKey: searchApiKey,
      );

      AlgoliaQuery query =
          algolia.instance.index(indexToQuery).query(searchText.trim());

      return (await query.getObjects()).hits;
    } else {
      return [];
    }
  }
}
