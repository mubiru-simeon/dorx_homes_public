import 'package:dorx/models/language.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../constants/constants.dart';
import '../services/services.dart';

class FloatingSearchWidget extends StatelessWidget {
  final Function(String) search;
  final bool searching;
  final List<SearchResult> results;
  final Function toggleSearchVisible;
  final bool searchVisible;
  final Function clearList;

  const FloatingSearchWidget({
    Key key,
    @required this.search,
    @required this.searching,
    @required this.results,
    @required this.toggleSearchVisible,
    @required this.searchVisible,
    @required this.clearList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            child: GestureDetector(
              onTap: () {
                toggleSearchVisible();
              },
              child: CircleAvatar(
                child: Icon(
                  searchVisible ? Icons.close : Icons.search,
                ),
              ),
            ),
          ),
        ),
        if (searchVisible)
          Expanded(
            child: FloatingSearchBar(
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  search(query);
                }
              },
              hint: translation(context).search,
              scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
              transitionDuration: const Duration(milliseconds: 500),
              transitionCurve: Curves.easeInOut,
              physics: const BouncingScrollPhysics(),
              automaticallyImplyBackButton: false,
              progress: searching,
              debounceDelay: const Duration(milliseconds: 500),
              onQueryChanged: (query) {
                if (query.trim().isNotEmpty) {
                  search(query);
                }
              },
              transition: CircularFloatingSearchBarTransition(),
              actions: [
                FloatingSearchBarAction(
                  showIfOpened: true,
                  showIfClosed: false,
                  builder: (context, animation) {
                    final bar = FloatingSearchAppBar.of(context);

                    return ValueListenableBuilder<String>(
                      valueListenable: bar.queryNotifer,
                      builder: (context, query, _) {
                        final isEmpty = query.trim().isEmpty;

                        return SearchToClear(
                          isEmpty: isEmpty,
                          size: 24,
                          color: bar.style.iconColor,
                          duration: Duration(milliseconds: 900) * 0.5,
                          onTap: () {
                            if (!isEmpty) {
                              bar.clear();
                              clearList();
                            } else {
                              bar.isOpen = !bar.isOpen ||
                                  (!bar.hasFocus && bar.isAlwaysOpened);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
              builder: (context, transition) {
                if (results.isNotEmpty) {
                  return ClipRRect(
                    borderRadius: standardBorderRadius,
                    child: Material(
                        color: Theme.of(context).canvasColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: results
                              .map((e) => Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Material(
                                      elevation: standardElevation,
                                      borderRadius: standardBorderRadius,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: ListTile(
                                          onTap: () {
                                            e.onTap();
                                          },
                                          leading: CircleAvatar(
                                            backgroundImage: e.image != null
                                                ? UIServices().getImageProvider(
                                                    e.image,
                                                  )
                                                : null,
                                            child: e.image == null
                                                ? Icon(e.icon)
                                                : null,
                                          ),
                                          title: Text(
                                            e.title,
                                          ),
                                          subtitle: Text(
                                            e.description,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        )),
                  );
                } else {
                  return SizedBox(
                    height: 1,
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}

class SearchResult {
  String _title;
  Function _onTap;
  String _description;
  IconData _icon;
  String _image;

  String get title => _title;
  Function get onTap => _onTap;
  String get description => _description;
  IconData get icon => _icon;
  String get image => _image;

  SearchResult.fromData({
    @required String title,
    @required Function onTap,
    @required String description,
    @required IconData icon,
    @required String image,
  }) {
    _title = title;
    _onTap = onTap;
    _description = description;
    _icon = icon;
    _image = image;
  }
}
