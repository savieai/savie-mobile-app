import 'dart:io';
import 'dart:typed_data';

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
        pathFilterOption: const PMPathFilter(
          darwin: PMDarwinPathFilter(
            subType: <PMDarwinAssetCollectionSubtype>[
              PMDarwinAssetCollectionSubtype.albumRegular,
              PMDarwinAssetCollectionSubtype.albumImported,
              PMDarwinAssetCollectionSubtype.smartAlbumSelfPortraits,
              PMDarwinAssetCollectionSubtype.smartAlbumSelfPortraits,
              PMDarwinAssetCollectionSubtype.smartAlbumScreenshots,
            ],
          ),
        ),
      );

      emit(CameraRollState.fecthed(
        albums: paths,
        selectedAlbum: paths.first,
        photos: await _getPhotos(
          album: paths.first,
          start: _currentStartIndex,
          end: _currentStartIndex + _batch,
        ),
        selectedPhotoIds: <String>{},
      ));
    }
  }

  Future<List<CameraRollPhoto>> _getPhotos({
    required AssetPathEntity album,
    required int start,
    required int end,
  }) async {
    final List<AssetEntity> assets = await album.getAssetListRange(
      start: start,
      end: end,
    );

    final List<CameraRollPhoto> photos = await Future.wait(
      assets.map(
        (AssetEntity asset) async => CameraRollPhoto(
          assetEntity: asset,
          thumbnailData: await asset.thumbnailDataWithSize(
            const ThumbnailSize(400, 400),
          ),
        ),
      ),
    );

    return photos;
  }

  int _currentStartIndex = 0;
  final int _batch = 40;

  Future<void> selectAlbum(AssetPathEntity album) async {
    if (state is! CameraRollStateFetched) {
      return;
    }

    if ((state as CameraRollStateFetched).selectedAlbum.id == album.id) {
      return;
    }

    _shouldLoad = true;
    _currentStartIndex = 0;

    emit((state as CameraRollStateFetched).copyWith(
      selectedAlbum: album,
      photos: null,
    ));

    emit((state as CameraRollStateFetched).copyWith(
      photos: await _getPhotos(
        album: album,
        start: _currentStartIndex,
        end: _currentStartIndex + _batch,
      ),
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

    final List<CameraRollPhoto> nextPhotos = await _getPhotos(
      album: album,
      start: _currentStartIndex,
      end: _currentStartIndex + _batch,
    );

    if (nextPhotos.length != _batch) {
      _shouldLoad = false;
    }

    emit((state as CameraRollStateFetched).copyWith(
      photos: <CameraRollPhoto>[
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

  Future<List<File>> getSelectedPhotos() async {
    if (state is CameraRollStateFetched) {
      final Set<String> selectedPhotoIds =
          (state as CameraRollStateFetched).selectedPhotoIds.toSet();

      final List<CameraRollPhoto> photos = (state as CameraRollStateFetched)
              .photos
              ?.where((CameraRollPhoto e) =>
                  selectedPhotoIds.contains(e.assetEntity.id))
              .toList() ??
          <CameraRollPhoto>[];

      final List<File?> files = await Future.wait(
        photos.map((CameraRollPhoto e) => e.assetEntity.file),
      );

      return files.nonNulls.toList();
    }

    return <File>[];
  }
}
