import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../application/application.dart';
import '../../../../cubit/cubit.dart';
import 'widget/widget.dart';

@RoutePage()
class CameraRollPage extends StatefulWidget {
  const CameraRollPage({super.key});

  @override
  State<CameraRollPage> createState() => _CameraRollPageState();
}

class _CameraRollPageState extends State<CameraRollPage> {
  late final CameraRollCubit _cameraRollCubit;

  @override
  void initState() {
    super.initState();
    _cameraRollCubit = getIt.get<CameraRollCubit>();
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.mediaSelection.screenOpened);
  }

  @override
  void dispose() {
    _cameraRollCubit.close();
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.mediaSelection.screenClosed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CameraRollCubit>.value(
      value: _cameraRollCubit,
      child: Scaffold(
        appBar: const CameraRollTopBar(),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: MediaQuery.paddingOf(context).copyWith(
                  bottom: MediaQuery.paddingOf(context).bottom + 56,
                ),
              ),
              child: const CameraRollPhotos(),
            ),
            const _AnimatedCameraRollBottomBar(),
            const _AnimatedCameraRollMessageView(),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCameraRollMessageView extends StatelessWidget {
  const _AnimatedCameraRollMessageView();

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedPhotos = context.select<CameraRollCubit, bool>(
      (CameraRollCubit cubit) => cubit.state.map(
        loading: (_) => false,
        fecthed: (CameraRollStateFetched fetched) =>
            fetched.selectedPhotoIds.isNotEmpty,
      ),
    );

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      bottom: hasSelectedPhotos
          ? 0
          : (-64 - MediaQuery.viewPaddingOf(context).bottom),
      left: 0,
      right: 0,
      curve: Curves.linearToEaseOut,
      child: AnimatedOpacity(
        opacity: hasSelectedPhotos ? 1 : 0.5,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linearToEaseOut,
        child: const CameraRollMessageView(),
      ),
    );
  }
}

class _AnimatedCameraRollBottomBar extends StatelessWidget {
  const _AnimatedCameraRollBottomBar();

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedPhotos = context.select<CameraRollCubit, bool>(
      (CameraRollCubit cubit) => cubit.state.map(
        loading: (_) => false,
        fecthed: (CameraRollStateFetched fetched) =>
            fetched.selectedPhotoIds.isNotEmpty,
      ),
    );

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      bottom: hasSelectedPhotos ? -20 : 0,
      left: 0,
      right: 0,
      curve: Curves.linearToEaseOut,
      child: const CameraRollBottomBar(),
    );
  }
}
