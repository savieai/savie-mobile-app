import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'context_menu_cubit.dart';

ContextMenuState _lastContextMenuState = ContextMenuState.notShown;
double _lastBottomViewInsetHeight = 0;

class ContextMenuListener extends StatelessWidget {
  const ContextMenuListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return BlocBuilder<ContextMenuCubit, ContextMenuState>(
      builder: (BuildContext context, ContextMenuState state) {
        final bool wasShown = _lastContextMenuState == ContextMenuState.shown;
        final bool isShown = state == ContextMenuState.shown;

        if (!wasShown && isShown) {
          _lastBottomViewInsetHeight = MediaQuery.viewInsetsOf(context).bottom;
        }

        _lastContextMenuState = state;
        final EdgeInsets viewInsets = mediaQuery.viewInsets;

        return MediaQuery(
          data: isShown
              ? mediaQuery.copyWith(
                  viewInsets: viewInsets.copyWith(
                    bottom: max(_lastBottomViewInsetHeight, viewInsets.bottom),
                  ),
                )
              : mediaQuery,
          child: child,
        );
      },
    );
  }
}
