part of 'camera_roll_cubit.dart';

@freezed
class CameraRollState with _$CameraRollState {
  factory CameraRollState.loading() = CameraRollStateLoading;

  factory CameraRollState.fecthed({
    required List<AssetPathEntity> albums,
    required AssetPathEntity selectedAlbum,
    required List<CameraRollPhoto>? photos,
    required Set<String> selectedPhotoIds,
  }) = CameraRollStateFetched;
}

@freezed
class CameraRollPhoto with _$CameraRollPhoto {
  factory CameraRollPhoto({
    required AssetEntity assetEntity,
    required Uint8List? thumbnailData,
  }) = _CameraRollPhoto;
}
