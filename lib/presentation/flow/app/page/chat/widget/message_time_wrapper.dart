import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../presentation.dart';
import '../cubit/cubit.dart';

class MessageTimeWrapper extends StatelessWidget {
  const MessageTimeWrapper({
    super.key,
    required this.time,
    required this.child,
  });

  final DateTime time;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatHorizontalDragCubit, double>(
      builder: (BuildContext context, double state) {
        return Transform.translate(
          offset: Offset(state, 0),
          child: Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              child,
              Align(
                alignment: FractionalOffset.centerLeft,
                child: Transform.translate(
                  offset: Offset(MediaQuery.sizeOf(context).width - 16, 0),
                  child: Text(
                    DateFormat('hh:mm').format(time),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
