part of 'camera_roll_cubit.dart';

@freezed
class CameraRollState with _$CameraRollState {
  factory CameraRollState.loading() = CameraRollStateLoading;

  factory CameraRollState.fecthed({
    required List<AssetPathEntity> albums,
    required AssetPathEntity selectedAlbum,
    required List<AssetEntity>? photos,
    required Set<String> selectedPhotoIds,
  }) = CameraRollStateFetched;
}
