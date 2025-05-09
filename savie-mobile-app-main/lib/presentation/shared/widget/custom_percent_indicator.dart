import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CustomPercentIndicator extends StatelessWidget {
  const CustomPercentIndicator({
    super.key,
    required this.progress,
    this.color,
  });

  final double? progress;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 16,
      alignment: Alignment.center,
      child: progress == null
          ? SizedBox(
              key: const Key('progress_indicator'),
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                color: color ?? Colors.white,
                strokeWidth: 1.5,
                strokeCap: StrokeCap.butt,
              ),
            )
          : FittedBox(
              child: CircularPercentIndicator(
                key: const Key('percent_indicator'),
                lineWidth: 1.5,
                percent: progress!,
                radius: 7 + 0.75,
                progressColor: color ?? Colors.white,
                backgroundColor: Colors.transparent,
              ),
            ),
    );
  }
}
