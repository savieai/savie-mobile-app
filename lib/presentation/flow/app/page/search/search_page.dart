import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../presentation.dart';
import 'widget/widget.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.paddingOf(context).top,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(
              children: <Widget>[
                Expanded(child: _SearchField()),
                SizedBox(width: 16),
                _CancelButton(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Expanded(child: _TabView()),
        ],
      ),
    );
  }
}

class _TabView extends StatefulWidget {
  const _TabView();

  @override
  State<_TabView> createState() => _TabViewState();
}

class _TabViewState extends State<_TabView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 4, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: <String>['Images', 'Links', 'Files', 'Voice']
              .mapIndexed((int index, String e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (BuildContext context, Widget? child) {
                  return DefaultTextStyle(
                    style: TextStyle(
                      color: Color.lerp(
                        AppColors.textPrimary,
                        AppColors.textSecondary,
                        (_tabController.animation!.value - index)
                            .abs()
                            .clamp(0, 1),
                      ),
                    ),
                    child: child ?? const SizedBox(),
                  );
                },
                child: Text(
                  e,
                  style: AppTextStyles.paragraph,
                ),
              ),
            );
          }).toList(),
          dividerColor: AppColors.strokeSecondaryAlpha,
          dividerHeight: 2,
          indicatorColor: AppColors.iconAccent,
          indicatorSize: TabBarIndicatorSize.label,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              SearchImages(),
              SearchLinks(),
              SearchFiles(),
              SearchAudioFiles(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      minLines: 1,
      cursorColor: AppColors.iconAccent,
      padding: const EdgeInsets.symmetric(
        vertical: 9,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundChatInput,
      ),
      placeholder: 'Search',
      style: AppTextStyles.paragraph,
      placeholderStyle: AppTextStyles.paragraph.copyWith(
        color: AppColors.textSecondary,
      ),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Assets.icons.search24.svg(
          colorFilter: const ColorFilter.mode(
            AppColors.iconSecodary,
            BlendMode.srcIn,
          ),
        ),
      ),
      suffix: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Assets.icons.calendarSearch24.svg(
          colorFilter: const ColorFilter.mode(
            AppColors.iconSecodary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: () {},
      child: Text(
        'Cancel',
        style: AppTextStyles.paragraph.copyWith(
          color: AppColors.iconAccent,
        ),
      ),
    );
  }
}
