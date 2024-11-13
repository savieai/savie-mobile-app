import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../application/application.dart';
import '../../../../../../domain/domain.dart';

part 'search_cubit.freezed.dart';
part 'search_state.dart';

@Injectable()
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchMessagesUseCase) : super(SearchState.initial) {
    _timer = Timer.periodic(
      const Duration(milliseconds: 750),
      (_) => _searchMessages(),
    );
    _searchMessages();
  }

  final SearchMessagesUseCase _searchMessagesUseCase;
  late final Timer _timer;

  SearchResultType? _oldType;
  SearchResultType _newType = SearchResultType.image;
  String _oldQuery = '';
  String _newQuery = '';

  void updateSearchResultType(SearchResultType type) {
    _newType = type;
    _searchMessages();
  }

  // ignore: use_setters_to_change_properties
  void updateQuery(String query) {
    _newQuery = query;
  }

  Future<void> _searchMessages() async {
    if (_newQuery == _oldQuery && _newType == _oldType) {
      return;
    }

    _oldQuery = _newQuery;
    _oldType = _newType;

    final String newQuery = _newQuery;
    final SearchResultType newType = _newType;

    switch (newType) {
      case SearchResultType.image:
        emit(state.copyWith(images: const TabSearchState.fetching()));
      case SearchResultType.file:
        emit(state.copyWith(files: const TabSearchState.fetching()));
      case SearchResultType.link:
        emit(state.copyWith(links: const TabSearchState.fetching()));
      case SearchResultType.voice:
        emit(state.copyWith(audios: const TabSearchState.fetching()));
    }

    final List<SearchResult> searchResult =
        await _searchMessagesUseCase.execute(
      query: newQuery,
      type: newType,
    );

    if (isClosed) {
      return;
    }

    switch (newType) {
      case SearchResultType.image:
        emit(SearchState.initial.copyWith(
          images: TabSearchState.fetched(data: searchResult),
        ));
      case SearchResultType.file:
        emit(SearchState.initial.copyWith(
          files: TabSearchState.fetched(data: searchResult),
        ));
      case SearchResultType.link:
        emit(SearchState.initial.copyWith(
          links: TabSearchState.fetched(data: searchResult),
        ));
      case SearchResultType.voice:
        emit(SearchState.initial.copyWith(
          audios: TabSearchState.fetched(data: searchResult),
        ));
    }
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
