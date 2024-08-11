import 'package:flutter/cupertino.dart';

import '../../presentation.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      onPressed: onPressed,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.iconAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: AppTextStyles.paragraph.copyWith(
            color: AppColors.textInvert,
          ),
          child: child,
        ),
      ),
    );
  }
}
