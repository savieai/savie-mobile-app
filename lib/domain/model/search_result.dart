import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult.image({
    required String id,
    required String messageId,
    required DateTime date,
    required String name,
    required String remoteUrl,
  }) = ImageSearchResult;

  const factory SearchResult.link({
    required String id,
    required String messageId,
    required DateTime date,
    required String url,
  }) = LinkSearchResult;

  // const factory SearchResult.file({
  //   required bool isPending,
  //   required String id,
  //   required DateTime date,
  //   required Attachment file,
  // }) = FileMessage;

  const SearchResult._();
}
