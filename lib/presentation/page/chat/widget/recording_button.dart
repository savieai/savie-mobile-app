import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../presentation.dart';

class RecordingButton extends StatelessWidget {
  const RecordingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        context.read<RecordingCubit>().startRecording();
      },
      onLongPressEnd: (_) {
        context.read<RecordingCubit>().finishRecording();
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Assets.icons.mic24.svg(
          colorFilter: const ColorFilter.mode(
            AppColors.iconSecodary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
