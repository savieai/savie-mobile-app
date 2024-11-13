import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../application/application.dart';
import '../../../../../presentation.dart';
import '../../../../../router/app_router.gr.dart';
import '../../camera_roll/widget/widget.dart';

class FilePickerButton extends StatelessWidget {
  const FilePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      svgGenImage: Assets.icons.attachment24,
      color: AppColors.iconSecodary,
      onTap: () => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (Platform.isMacOS) {
      pushFilePicker(context);
      return;
    }

    context.router.push(const CameraRollRoute());
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.chat.mediaButtonClicked);
  }
}
