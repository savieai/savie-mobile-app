import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../presentation.dart';

class PopupTemplate extends StatelessWidget {
  const PopupTemplate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
              ),
              child: child,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: CustomIconButton(
                svgGenImage: Assets.icons.close24,
                color: AppColors.iconSecodary,
                onTap: context.router.maybePop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
