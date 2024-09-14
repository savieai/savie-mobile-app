part of 'search_cubit.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    required TabSearchState images,
    required TabSearchState links,
    required TabSearchState files,
    required TabSearchState audios,
  }) = _SearchState;

  const SearchState._();

  static const SearchState initial = SearchState(
    images: TabSearchState.initial(),
    links: TabSearchState.initial(),
    files: TabSearchState.initial(),
    audios: TabSearchState.initial(),
  );
}

@freezed
class TabSearchState with _$TabSearchState {
  const factory TabSearchState.initial() = _TabSearchInitial;
  const factory TabSearchState.fetching() = _TabSearchFetching;
  const factory TabSearchState.fetched({
    required List<SearchResult> data,
  }) = _TabSearchFetched;
}
