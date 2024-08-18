import 'package:flutter/material.dart';

import 'images_scrollbar.dart';

class SearchImages extends StatefulWidget {
  const SearchImages({super.key});

  @override
  State<SearchImages> createState() => _SearchImagesState();
}

class _SearchImagesState extends State<SearchImages> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ImagesScrollbar(
      controller: _scrollController,
      heightScrollThumb: 40,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          // SliverGrid.builder(
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 3,
          //     mainAxisSpacing: 2,
          //     crossAxisSpacing: 2,
          //   ),
          //   itemCount: 100,
          //   itemBuilder: (BuildContext context, int i) => CachedNetworkImage(
          //     imageUrl:
          //         'https://s.cafebazaar.ir/images/icons/com.Nature.WallappersQuick-f4c4352a-467d-4ffb-85e9-f4fa7645f1e2_512x512.png?x-img=v1/resize,h_256,w_256,lossless_false/optimize',
          //   ),
          // ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }
}
