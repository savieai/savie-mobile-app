import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../application/application.dart';
import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../../chat/widget/widget.dart';

class CameraRollMessageView extends StatefulWidget {
  const CameraRollMessageView({super.key});

  @override
  State<CameraRollMessageView> createState() => _CameraRollMessageViewState();
}

class _CameraRollMessageViewState extends State<CameraRollMessageView> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundChatInput,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Container(
        height: 64,
        alignment: Alignment.center,
        child: Row(
          children: <Widget>[
            Expanded(
              child: DefaultTextHeightBehavior(
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                child: CupertinoTextField(
                  controller: _controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                  minLines: 1,
                  cursorColor: AppColors.iconAccent,
                  decoration: const BoxDecoration(),
                  style: AppTextStyles.paragraph,
                  placeholderStyle: AppTextStyles.paragraph.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  placeholder: 'Add caption',
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              child: SendButton(
                onTap: () async {
                  final List<File> files =
                      await context.read<CameraRollCubit>().getSelectedPhotos();
                  // TODO: get message type
                  getIt
                      .get<TrackUseActivityUseCase>()
                      .execute(AppEvents.mediaSelection.sendClicked(
                        type: AppEventMessageType.imagesWithCaption,
                      ));

                  if (context.mounted) {
                    context.read<ChatCubit>().sendMessage(
                      textContents: <TextContent>[
                        TextContent.plainText(text: _controller.text),
                      ],
                      mediaPaths: files.map((File f) => f.path).toList(),
                    );
                    _controller.value = TextEditingValue.empty;
                    context.router.maybePop();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
