import 'package:flutter/material.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../../chat/widget/message_view/message_view.dart';

class SearchAudioFiles extends StatelessWidget {
  const SearchAudioFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: 100,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: AudioView(
            expand: true,
            previewInfo: index != 1,
            audioMessage: AudioMessage(
              // peeks: <double>[
              //   .0,
              //   .1,
              //   .2,
              //   .3,
              //   .4,
              //   .3,
              //   .2,
              //   .1,
              //   .2,
              //   .2,
              //   .2,
              //   .3,
              //   .4,
              //   .3,
              //   .3,
              //   .3
              // ],
              // path: '',
              // seconds: 44,
              id: '',
              date: DateTime.now(),
              name: '', fullUrl: '',
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => Container(
        color: AppColors.strokeSecondaryAlpha,
        height: 1,
      ),
    );
  }
}
