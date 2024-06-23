import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:photo_manager/photo_manager.dart';

part 'camera_roll_state.dart';
part 'camera_roll_cubit.freezed.dart';

@injectable
class CameraRollCubit extends Cubit<CameraRollState> {
  CameraRollCubit() : super(CameraRollState.loading()) {
    _init();
  }

  Future<void> _init() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps == PermissionState.authorized) {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      final List<int> lengths = await Future.wait(
        paths.map((AssetPathEntity e) => e.assetCountAsync),
      );

      final List<AssetPathEntity> albums =
          paths.whereIndexed((int index, _) => lengths[index] != 0).toList();

      emit(CameraRollState.fecthed(
        albums: albums,
        selectedAlbum: albums.first,
        photos: await albums.first.getAssetListRange(
          start: _currentStartIndex,
          end: _currentStartIndex + _batch,
        ),
        selectedPhotoIds: <String>{},
      ));
    }
  }

  int _currentStartIndex = 0;
  final int _batch = 20;

  Future<void> selectAlbum(AssetPathEntity album) async {
    _shouldLoad = true;
    _currentStartIndex = 0;

    if (state is CameraRollStateFetched) {
      emit((state as CameraRollStateFetched).copyWith(
        selectedAlbum: album,
        photos: null,
      ));
    }

    final List<AssetEntity> photos = await album.getAssetListRange(
      start: _currentStartIndex,
      end: _batch,
    );

    emit((state as CameraRollStateFetched).copyWith(
      photos: photos,
      selectedAlbum: album,
      selectedPhotoIds: <String>{},
    ));
  }

  bool _isLoading = false;
  bool _shouldLoad = true;
  Future<void> loadMore() async {
    if (_isLoading || !_shouldLoad) {
      return;
    }

    _isLoading = true;
    final AssetPathEntity album =
        (state as CameraRollStateFetched).selectedAlbum;

    _currentStartIndex += _batch;

    final List<AssetEntity> nextPhotos = await album.getAssetListRange(
      start: _currentStartIndex,
      end: _currentStartIndex + _batch,
    );

    if (nextPhotos.length != _batch) {
      _shouldLoad = false;
    }

    emit((state as CameraRollStateFetched).copyWith(
      photos: <AssetEntity>[
        ...(state as CameraRollStateFetched).photos!,
        ...nextPhotos
      ],
    ));
    _isLoading = false;
  }

  void togglePhotoId(String photoId) {
    if (state is CameraRollStateFetched) {
      final Set<String> selectedPhotoIds =
          (state as CameraRollStateFetched).selectedPhotoIds.toSet();

      if (selectedPhotoIds.contains(photoId)) {
        selectedPhotoIds.remove(photoId);
      } else {
        selectedPhotoIds.add(photoId);
      }

      emit((state as CameraRollStateFetched).copyWith(
        selectedPhotoIds: selectedPhotoIds,
      ));
    }
  }

  Future<List<String>> getSelectedPhotoPaths() async {
    if (state is CameraRollStateFetched) {
      final Set<String> selectedPhotoIds =
          (state as CameraRollStateFetched).selectedPhotoIds.toSet();

      final List<AssetEntity> photos = (state as CameraRollStateFetched)
              .photos
              ?.where((AssetEntity e) => selectedPhotoIds.contains(e.id))
              .toList() ??
          <AssetEntity>[];

      final List<String?> paths = await Future.wait(
        photos.map((AssetEntity e) => e.file.then((File? e) => e?.path)),
      );

      return paths.nonNulls.toList();
    }

    return <String>[];
  }
}
