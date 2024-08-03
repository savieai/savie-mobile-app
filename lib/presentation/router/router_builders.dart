import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

abstract class RouteBuilders {
  RouteBuilders._();

  static Route<T> materialWithModalsBuilder<T>(
    BuildContext context,
    Widget child,
    AutoRoutePage<T> page,
  ) {
    return MaterialWithModalsPageRoute<T>(
      settings: page,
      builder: (BuildContext context) {
        return child;
      },
    );
  }

  static Route<T> modalBottomSheet<T>(
    BuildContext context,
    Widget child,
    AutoRoutePage<T> page,
  ) {
    return CupertinoModalBottomSheetRoute<T>(
      expanded: true,
      settings: page,
      builder: (BuildContext context) {
        const Radius topRadius = Radius.circular(12);
        const BoxShadow shadow =
            BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);
        final double topSafeAreaPadding = MediaQuery.of(context).padding.top;
        final double topPadding = 10 + topSafeAreaPadding;
        final Color backgroundColor =
            CupertinoTheme.of(context).scaffoldBackgroundColor;

        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: topRadius),
            child: Container(
              decoration: BoxDecoration(
                  color: backgroundColor, boxShadow: const <BoxShadow>[shadow]),
              width: double.infinity,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  static Route<T> modalPopupSheet<T>(
    BuildContext context,
    Widget child,
    AutoRoutePage<T> page,
  ) {
    return CupertinoModalPopupRoute<T>(
      settings: page,
      builder: (BuildContext context) {
        return child;
      },
    );
  }
}
