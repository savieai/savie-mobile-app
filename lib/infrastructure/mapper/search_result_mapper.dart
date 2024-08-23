import '../../domain/domain.dart';

import '../infrastructure.dart';

sealed class SearchResultMapper {
  static SearchResult imageToDomain(ImageSearchResultDTO dto) {
    return SearchResult.image(
      id: dto.id,
      messageId: dto.messageId,
      date: dto.createdAt.toLocal(),
      image: Attachment(
        signedUrl: dto.signedUrl,
        name: dto.name,
        remoteStorageName: null,
        localFullPath: null,
      ),
    );
  }

  static SearchResult fileToDomain(FileSearchResultDTO dto) {
    return SearchResult.file(
      id: dto.id,
      messageId: dto.messageId,
      date: dto.createdAt.toLocal(),
      file: Attachment(
        signedUrl: dto.signedUrl,
        name: dto.name,
        remoteStorageName: null,
        localFullPath: null,
      ),
    );
  }

  static SearchResult linkToDomain(LinkSearchResultDTO dto) {
    return SearchResult.link(
      id: dto.id,
      messageId: dto.messageId,
      date: dto.createdAt.toLocal(),
      url: dto.url,
    );
  }
}
