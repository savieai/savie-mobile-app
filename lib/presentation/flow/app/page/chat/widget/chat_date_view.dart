import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../application/extension/date_time_x.dart';
import '../../../../../presentation.dart';

class ChatDateView extends StatelessWidget {
  const ChatDateView({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    late final String label;

    if (date.isToday) {
      label = 'Today';
    } else if (date.isYesterday) {
      label = 'Yesterday';
    } else if (date.isThisYear) {
      label = DateFormat('MMMM dd').format(date);
    } else {
      label = DateFormat('MMMM dd, YYYY').format(date);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary,
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          child: Text(
            label,
            style: AppTextStyles.callout.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
