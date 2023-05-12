library paginate_firestore;

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dorx/views/no_data_found_view.dart';
import 'package:provider/provider.dart';

import 'widgets.dart';

class BottomLoader extends StatelessWidget {
  const BottomLoader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 16, bottom: 24),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class EmptySeparator extends StatelessWidget {
  const EmptySeparator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 0,
      width: 0,
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    Key key,
    @required this.exception,
  }) : super(key: key);

  final Exception exception;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error occured: $exception'));
  }
}

class InitialLoader extends StatelessWidget {
  const InitialLoader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingWidget(),
    );
  }
}

class PaginationCubit extends Cubit<PaginationState> {
  PaginationCubit(
    this._limit,
    this._startAfterDocument, {
    this.isLive = false,
    this.includeMetadataChanges = false,
    this.options,
  }) : super(PaginationInitial());

  DocumentSnapshot _lastDocument;
  final int _limit;
  final DocumentSnapshot _startAfterDocument;
  final bool isLive;
  final bool includeMetadataChanges;
  final GetOptions options;

  final _streams = <StreamSubscription<QuerySnapshot>>[];

  void filterPaginatedList(String searchTerm) {
    if (state is PaginationLoaded) {
      final loadedState = state as PaginationLoaded;

      final filteredList = loadedState.documentSnapshots
          .where((document) => document
              .data()
              .toString()
              .toLowerCase()
              .contains(searchTerm.toLowerCase()))
          .toList();

      emit(loadedState.copyWith(
        documentSnapshots: filteredList,
        hasReachedEnd: loadedState.hasReachedEnd,
      ));
    }
  }

  void reScanAndReset(Query qq) {
    _lastDocument = null;

    _emitPaginatedState([]);
    refreshPaginatedList(qq);
  }

  void refreshPaginatedList(
    Query qq,
  ) async {
    _lastDocument = null;

    final localQuery = _getQuery(qq);
    if (isLive) {
      final listener = localQuery
          .snapshots(includeMetadataChanges: includeMetadataChanges)
          .listen((querySnapshot) {
        _emitPaginatedState(querySnapshot.docs);
      });

      _streams.add(listener);
    } else {
      final querySnapshot = await localQuery.get(options);
      _emitPaginatedState(querySnapshot.docs);
    }
  }

  void fetchPaginatedList(Query qq) {
    isLive ? _getLiveDocuments(qq) : _getDocuments(qq);
  }

  _getDocuments(Query qq) async {
    final localQuery = _getQuery(qq);
    try {
      if (state is PaginationInitial) {
        refreshPaginatedList(qq);
      } else if (state is PaginationLoaded) {
        final loadedState = state as PaginationLoaded;
        if (loadedState.hasReachedEnd) return;
        final querySnapshot = await localQuery.get(options);
        _emitPaginatedState(
          querySnapshot.docs,
          previousList:
              loadedState.documentSnapshots as List<QueryDocumentSnapshot>,
        );
      }
    } on PlatformException catch (exception) {
      // ignore: avoid_print
      print(exception);
      rethrow;
    }
  }

  _getLiveDocuments(Query qq) {
    final localQuery = _getQuery(qq);
    if (state is PaginationInitial) {
      refreshPaginatedList(qq);
    } else if (state is PaginationLoaded) {
      PaginationLoaded loadedState = state as PaginationLoaded;
      if (loadedState.hasReachedEnd) return;
      final listener = localQuery
          .snapshots(includeMetadataChanges: includeMetadataChanges)
          .listen((querySnapshot) {
        loadedState = state as PaginationLoaded;
        _emitPaginatedState(
          querySnapshot.docs,
          previousList:
              loadedState.documentSnapshots as List<QueryDocumentSnapshot>,
        );
      });

      _streams.add(listener);
    }
  }

  void _emitPaginatedState(
    List<QueryDocumentSnapshot> newList, {
    List<QueryDocumentSnapshot> previousList = const [],
  }) {
    _lastDocument = newList.isNotEmpty ? newList.last : null;
    emit(PaginationLoaded(
      documentSnapshots: _mergeSnapshots(previousList, newList),
      hasReachedEnd: newList.isEmpty,
    ));
  }

  List<QueryDocumentSnapshot> _mergeSnapshots(
    List<QueryDocumentSnapshot> previousList,
    List<QueryDocumentSnapshot> newList,
  ) {
    final prevIds = previousList.map((prevSnapshot) => prevSnapshot.id).toSet();
    newList.retainWhere((newSnapshot) => prevIds.add(newSnapshot.id));
    return previousList + newList;
  }

  Query _getQuery(
    Query<Object> query,
  ) {
    var localQuery = (_lastDocument != null)
        ? query.startAfterDocument(_lastDocument)
        : _startAfterDocument != null
            ? query.startAfterDocument(_startAfterDocument)
            : query;
    localQuery = localQuery.limit(_limit);
    return localQuery;
  }

  void dispose() {
    for (var listener in _streams) {
      listener.cancel();
    }
  }
}

class PaginateChangeListener extends ChangeNotifier {}

class PaginateResetChangeListener extends PaginateChangeListener {
  PaginateResetChangeListener();

  bool _reset = false;
  Query<Object> _query;

  resetPagination(
    bool value,
    Query<Object> qq,
  ) {
    _reset = value;
    _query = qq;

    if (value) {
      notifyListeners();
    }
  }

  bool get reset {
    return _reset;
  }

  Query<Object> get query {
    return _query;
  }
}

class PaginateRefreshedChangeListener extends PaginateChangeListener {
  PaginateRefreshedChangeListener();

  bool _refreshed = false;

  set refreshed(bool value) {
    _refreshed = value;
    if (value) {
      notifyListeners();
    }
  }

  set reset(bool value) {
    _refreshed = value;
    if (value) {
      notifyListeners();
    }
  }

  bool get refreshed {
    return _refreshed;
  }
}

class PaginateFilterChangeListener extends PaginateChangeListener {
  PaginateFilterChangeListener();

  String _filterTerm;

  set searchTerm(String value) {
    _filterTerm = value;
    if (value.isNotEmpty) {
      notifyListeners();
    }
  }

  String get searchTerm {
    return _filterTerm;
  }
}

@immutable
abstract class PaginationState {}

class PaginationInitial extends PaginationState {}

class PaginationError extends PaginationState {
  final Exception error;
  PaginationError({
    @required this.error,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationError && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}

class PaginationLoaded extends PaginationState {
  PaginationLoaded({
    @required this.documentSnapshots,
    @required this.hasReachedEnd,
  });

  final bool hasReachedEnd;
  final List<DocumentSnapshot> documentSnapshots;

  PaginationLoaded copyWith({
    bool hasReachedEnd,
    List<DocumentSnapshot> documentSnapshots,
  }) {
    return PaginationLoaded(
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      documentSnapshots: documentSnapshots ?? this.documentSnapshots,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationLoaded &&
        other.hasReachedEnd == hasReachedEnd &&
        listEquals(other.documentSnapshots, documentSnapshots);
  }

  @override
  int get hashCode => hasReachedEnd.hashCode ^ documentSnapshots.hashCode;
}

class PaginateFirestore extends StatefulWidget {
  const PaginateFirestore({
    Key key,
    @required this.itemBuilder,
    @required this.query,
    @required this.itemBuilderType,
    this.gridDelegate =
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    this.startAfterDocument,
    this.itemsPerPage = 15,
    this.onError,
    this.onReachedEnd,
    this.onLoaded,
    this.onEmpty,
    this.separator = const EmptySeparator(),
    this.initialLoader = const InitialLoader(),
    this.bottomLoader = const BottomLoader(),
    this.shrinkWrap = false,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(0),
    this.physics,
    this.listeners,
    this.scrollController,
    this.allowImplicitScrolling = false,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.pageController,
    this.onPageChanged,
    this.header,
    this.footer,
    this.isLive = false,
    this.includeMetadataChanges = false,
    this.options,
  }) : super(key: key);

  final Widget bottomLoader;
  final Widget onEmpty;
  final SliverGridDelegate gridDelegate;
  final Widget initialLoader;
  final PaginateBuilderType itemBuilderType;
  final int itemsPerPage;
  final List<ChangeNotifier> listeners;
  final EdgeInsets padding;
  final ScrollPhysics physics;
  final Query query;
  final bool reverse;
  final bool allowImplicitScrolling;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollController scrollController;
  final PageController pageController;
  final Axis scrollDirection;
  final Widget separator;
  final bool shrinkWrap;
  final bool isLive;
  final DocumentSnapshot startAfterDocument;
  final Widget header;
  final Widget footer;

  /// Use this only if `isLive = false`
  final GetOptions options;

  /// Use this only if `isLive = true`
  final bool includeMetadataChanges;

  @override
  State<PaginateFirestore> createState() => _PaginateFirestoreState();

  final Widget Function(Exception) onError;

  final Widget Function(BuildContext, List<DocumentSnapshot>, int) itemBuilder;

  final void Function(PaginationLoaded) onReachedEnd;

  final void Function(PaginationLoaded) onLoaded;

  final void Function(int) onPageChanged;
}

class _PaginateFirestoreState extends State<PaginateFirestore> {
  PaginationCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginationCubit, PaginationState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is PaginationInitial) {
          return Center(
            child: widget.initialLoader,
          );
        } else if (state is PaginationError) {
          return Center(
            child: (widget.onError != null)
                ? widget.onError(state.error)
                : ErrorDisplay(exception: state.error),
          );
        } else {
          final loadedState = state as PaginationLoaded;
          if (widget.onLoaded != null) {
            widget.onLoaded(loadedState);
          }
          if (loadedState.hasReachedEnd && widget.onReachedEnd != null) {
            widget.onReachedEnd(loadedState);
          }

          if (loadedState.documentSnapshots.isEmpty) {
            return Center(
              child: widget.onEmpty ??
                  NoDataFound(
                    text: "No Data Found",
                  ),
            );
          }
          return widget.itemBuilderType == PaginateBuilderType.listView
              ? _buildListView(loadedState)
              : widget.itemBuilderType == PaginateBuilderType.gridView
                  ? _buildGridView(loadedState)
                  : _buildPageView(loadedState);
        }
      },
    );
  }

  /*  Widget _buildWithScrollView(BuildContext context, Widget child) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: child,
      ),
    );
  } */

  @override
  void dispose() {
    widget.scrollController?.dispose();
    _cubit?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.listeners != null) {
      for (var listener in widget.listeners) {
        if (listener is PaginateRefreshedChangeListener) {
          listener.addListener(() {
            if (listener.refreshed) {
              _cubit.refreshPaginatedList(
                widget.query,
              );
            }
          });
        } else if (listener is PaginateFilterChangeListener) {
          listener.addListener(() {
            if (listener.searchTerm.isNotEmpty) {
              _cubit.filterPaginatedList(listener.searchTerm);
            }
          });
        } else if (listener is PaginateResetChangeListener) {
          listener.addListener(() {
            if (listener.reset) {
              _cubit.reScanAndReset(
                listener.query,
              );
            }
          });
        }
      }
    }

    _cubit = PaginationCubit(
      widget.itemsPerPage,
      widget.startAfterDocument,
      isLive: widget.isLive,
    )..fetchPaginatedList(widget.query);
    super.initState();
  }

  Widget _buildGridView(PaginationLoaded loadedState) {
    // _cubit.reScanAndReset();
    var gridView = CustomScrollView(
      reverse: widget.reverse,
    
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      slivers: [
        if (widget.header != null) widget.header,
        SliverPadding(
          padding: widget.padding,
          sliver: SliverGrid(
            gridDelegate: widget.gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= loadedState.documentSnapshots.length) {
                  _cubit.fetchPaginatedList(widget.query);
                  return widget.bottomLoader;
                }
                return widget.itemBuilder(
                  context,
                  loadedState.documentSnapshots,
                  index,
                );
              },
              childCount: loadedState.hasReachedEnd
                  ? loadedState.documentSnapshots.length
                  : loadedState.documentSnapshots.length + 1,
            ),
          ),
        ),
        if (widget.footer != null) widget.footer,
      ],
    );

    if (widget.listeners != null && widget.listeners.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners
            .map((listener) => ChangeNotifierProvider(
                  create: (context) => listener,
                ))
            .toList(),
        child: gridView,
      );
    }

    return gridView;
  }

  Widget _buildListView(PaginationLoaded loadedState) {
    var listView = CustomScrollView(
      reverse: widget.reverse,
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      slivers: [
        if (widget.header != null) widget.header,
        SliverPadding(
          padding: widget.padding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final itemIndex = index ~/ 2;
                if (index.isEven) {
                  if (itemIndex >= loadedState.documentSnapshots.length) {
                    _cubit.fetchPaginatedList(widget.query);
                    return widget.bottomLoader;
                  }
                  return widget.itemBuilder(
                    context,
                    loadedState.documentSnapshots,
                    itemIndex,
                  );
                }
                return widget.separator;
              },
              semanticIndexCallback: (widget, localIndex) {
                if (localIndex.isEven) {
                  return localIndex ~/ 2;
                }
                // ignore: avoid_returning_null
                return null;
              },
              childCount: max(
                  0,
                  (loadedState.hasReachedEnd
                              ? loadedState.documentSnapshots.length
                              : loadedState.documentSnapshots.length + 1) *
                          2 -
                      1),
            ),
          ),
        ),
        if (widget.footer != null) widget.footer,
      ],
    );

    if (widget.listeners != null && widget.listeners.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners
            .map((listener) => ChangeNotifierProvider(
                  create: (context) => listener,
                ))
            .toList(),
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildPageView(PaginationLoaded loadedState) {
    var pageView = Padding(
      padding: widget.padding,
      child: PageView.custom(
        reverse: widget.reverse,
        allowImplicitScrolling: widget.allowImplicitScrolling,
        controller: widget.pageController,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        onPageChanged: widget.onPageChanged,
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= loadedState.documentSnapshots.length) {
              _cubit.fetchPaginatedList(widget.query);
              return widget.bottomLoader;
            }
            return widget.itemBuilder(
              context,
              loadedState.documentSnapshots,
              index,
            );
          },
          childCount: loadedState.hasReachedEnd
              ? loadedState.documentSnapshots.length
              : loadedState.documentSnapshots.length + 1,
        ),
      ),
    );

    if (widget.listeners != null && widget.listeners.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners
            .map((listener) => ChangeNotifierProvider(
                  create: (context) => listener,
                ))
            .toList(),
        child: pageView,
      );
    }

    return pageView;
  }
}

enum PaginateBuilderType { listView, gridView, pageView }
