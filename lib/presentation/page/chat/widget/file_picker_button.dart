import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../../presentation.dart';
import '../../../router/app_router.gr.dart';

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
    context.router.push(const CameraRollRoute());
  }
}
