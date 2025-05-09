import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../presentation.dart';
import '../router/app_router.gr.dart';

class LogsWrapper extends StatelessWidget {
  const LogsWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;

    // return FloatingDraggableWidget(
    //   floatingWidgetHeight: 100,
    //   floatingWidgetWidth: 100,
    //   autoAlign: true,
    //   mainScreenWidget: child,
    //   resizeToAvoidBottomInset: false,
    //   floatingWidget: Padding(
    //     padding: const EdgeInsets.all(25),
    //     child: Container(
    //       decoration: const BoxDecoration(
    //         color: AppColors.iconAccent,
    //         shape: BoxShape.circle,
    //       ),
    //       child: IconButton(
    //         onPressed: () {
    //           getIt.get<AppRouter>().push(const LogsRoute());
    //         },
    //         color: Colors.white,
    //         icon: const Icon(Icons.developer_board),
    //       ),
    //     ),
    //   ),
    // );
  }
}
