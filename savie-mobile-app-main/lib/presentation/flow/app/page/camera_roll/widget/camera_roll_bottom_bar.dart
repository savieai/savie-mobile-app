import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../application/application.dart';
import '../../../../../presentation.dart';

class CameraRollBottomBar extends StatelessWidget {
  const CameraRollBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundChatInput,
        border: Border(
          top: BorderSide(
            color: AppColors.strokeSecondaryAlpha,
          ),
        ),
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _BottomBarButton(
              svgGenImage: Assets.icons.gallery24,
              caption: 'Gallery',
              color: AppColors.iconAccent,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                getIt
                    .get<TrackUseActivityUseCase>()
                    .execute(AppEvents.mediaSelection.filesClicked);
                pushFilePicker(context);
              },
              child: _BottomBarButton(
                svgGenImage: Assets.icons.folder24,
                caption: 'Files',
                color: AppColors.iconSecodary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  const _BottomBarButton({
    required this.svgGenImage,
    required this.caption,
    required this.color,
  });

  final SvgGenImage svgGenImage;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.sizeOf(context).width / 2 - 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 2),
          svgGenImage.svg(
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: AppTextStyles.caption.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> pushFilePicker(BuildContext context) async {
  final ChatCubit chatCubit = context.read<ChatCubit>();
  context.router.maybePop();

  final FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result == null || result.files.isEmpty) {
    return;
  }

  chatCubit.sendFile(result.files.firstOrNull?.path);
}
