import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/application.dart';
import '../../domain/domain.dart';

import '../infrastructure.dart';

sealed class SearchResultMapper {
  static SearchResult imageToDomain(ImageSearchResultDTO dto) {
    return SearchResult.image(
      messageId: dto.messageId,
      date: dto.createdAt.toLocal(),
      image: Attachment(
        signedUrl: Supabase.instance.client.storage
            .from('message_attachments')
            .getAuthenticatedUrl(dto.name),
        name: dto.name,
        remoteStorageName: null,
        localFullPath: null,
      ),
    );
  }

  static SearchResult fileToDomain(FileSearchResultDTO dto) {
    return SearchResult.file(
      messageId: dto.messageId,
      date: dto.createdAt.toLocal(),
      file: Attachment(
        signedUrl: Supabase.instance.client.storage
            .from('message_attachments')
            .getAuthenticatedUrl(dto.name),
        name: dto.name,
        remoteStorageName: null,
        localFullPath: null,
      ),
    );
  }

  static SearchResult linkToDomain(LinkSearchResultDTO dto) {
    return SearchResult.link(
      messageId: dto.messageId,
      date: dto.createdAt.toLocal(),
      url: dto.url,
    );
  }
}
