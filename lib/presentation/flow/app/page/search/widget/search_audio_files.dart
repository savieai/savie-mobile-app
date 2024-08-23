import 'package:flutter/material.dart';

class SearchAudioFiles extends StatelessWidget {
  const SearchAudioFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
    // return ListView.separated(
    //   padding: EdgeInsets.fromLTRB(
    //     20,
    //     4,
    //     20,
    //     MediaQuery.paddingOf(context).bottom,
    //   ),
    //   itemCount: 0,
    //   itemBuilder: (BuildContext context, int index) {
    //     return Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 12),
    //       child: AudioView(
    //         expand: true,
    //         previewInfo: index != 1,
    //         audioMessage: AudioMessage(
    //           // peeks: <double>[
    //           //   .0,
    //           //   .1,
    //           //   .2,
    //           //   .3,
    //           //   .4,
    //           //   .3,
    //           //   .2,
    //           //   .1,
    //           //   .2,
    //           //   .2,
    //           //   .2,
    //           //   .3,
    //           //   .4,
    //           //   .3,
    //           //   .3,
    //           //   .3
    //           // ],
    //           // path: '',
    //           // seconds: 44,
    //           id: '',
    //           date: DateTime.now(),
    //           name: '', localUrl: '',
    //           remoteUrl: null,
    //           isPending: false,
    //         ),
    //       ),
    //     );
    //   },
    //   separatorBuilder: (_, __) => Container(
    //     color: AppColors.strokeSecondaryAlpha,
    //     height: 1,
    //   ),
    // );
  }
}
