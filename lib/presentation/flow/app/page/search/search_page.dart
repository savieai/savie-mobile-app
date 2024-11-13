import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../application/application.dart';
import '../../../../../domain/enum/enum.dart';
import '../../../../presentation.dart';
import '../../../../router/app_router.gr.dart';
import 'cubit/search_cubit.dart';
import 'widget/widget.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchCubit _searchCubit = getIt.get<SearchCubit>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (getIt.get<ShouldDisplaySavieProPopupUseCase>().execute()) {
        Future<void>.delayed(const Duration(milliseconds: 125), () {
          if (context.mounted && mounted) {
            context.router.push(const ProComingSoonRoute());
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>.value(
      value: _searchCubit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.paddingOf(context).top,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: <Widget>[
                  Expanded(child: _SearchField(controller: _searchController)),
                  const SizedBox(width: 16),
                  const _CancelButton(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (BuildContext context, TextEditingValue value, _) {
                return Expanded(
                  child: value.text.isEmpty
                      ? const _TabView()
                      : SearchChat(
                          searchController: _searchController,
                        ),
                );
              },
            ),
          ],
        ),
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
  void initState() {
    super.initState();
    final SearchCubit cubit = context.read<SearchCubit>();
    _tabController.addListener(() {
      final int index = _tabController.index;
      switch (index) {
        case 0:
          cubit.updateSearchResultType(SearchResultType.image);
        case 1:
          cubit.updateSearchResultType(SearchResultType.link);
        case 2:
          cubit.updateSearchResultType(SearchResultType.file);
        case 3:
          cubit.updateSearchResultType(SearchResultType.voice);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          child: HeroVisibleArea(
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
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      minLines: 1,
      cursorColor: AppColors.iconAccent,
      padding: const EdgeInsets.symmetric(
        vertical: 9,
        horizontal: 8,
      ),
      focusNode: _focusNode,
      controller: widget.controller,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundChatInput,
      ),
      placeholder: 'Search',
      autofocus: true,
      style: AppTextStyles.paragraph,
      placeholderStyle: AppTextStyles.paragraph.copyWith(
        color: AppColors.textSecondary,
      ),
      onTapOutside: (_) {
        _focusNode.unfocus();
      },
      onChanged: context.read<SearchCubit>().updateQuery,
      prefix: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Assets.icons.search24.svg(
          height: Platform.isMacOS ? 20 : 24,
          colorFilter: const ColorFilter.mode(
            AppColors.iconSecodary,
            BlendMode.srcIn,
          ),
        ),
      ),
      // suffix: Padding(
      //   padding: const EdgeInsets.only(right: 8),
      //   child: Assets.icons.calendarSearch24.svg(
      //     colorFilter: const ColorFilter.mode(
      //       AppColors.iconSecodary,
      //       BlendMode.srcIn,
      //     ),
      //   ),
      // ),
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
      onPressed: () {
        context.router.maybePop();
      },
      child: Text(
        'Cancel',
        style: AppTextStyles.paragraph.copyWith(
          color: AppColors.iconAccent,
        ),
      ),
    );
  }
}
