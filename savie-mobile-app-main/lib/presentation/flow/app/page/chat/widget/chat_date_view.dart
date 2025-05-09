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
      label = DateFormat('MMMM dd, yyyy').format(date);
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpaces.space400) +
            EdgeInsets.only(top: AppSpaces.space300 / 3),
        child: Text(
          label,
          style: AppTextStyles.callout.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
