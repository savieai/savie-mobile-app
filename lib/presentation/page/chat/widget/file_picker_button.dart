import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../presentation.dart';

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
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    if (context.mounted) {
      context.read<ChatCubit>().sendMedia(
            result.files.map((PlatformFile e) => e.path).nonNulls.toList(),
          );
    }
  }
}
