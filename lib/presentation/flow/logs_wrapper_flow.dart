import 'package:auto_route/auto_route.dart';
import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../presentation.dart';
import '../router/app_router.gr.dart';

@RoutePage(name: 'LogsWrapperFlowRoute')
class LogsWrapperFlow extends StatelessWidget {
  const LogsWrapperFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingDraggableWidget(
      floatingWidgetHeight: 100,
      floatingWidgetWidth: 100,
      autoAlign: true,
      mainScreenWidget: const AutoRouter(),
      resizeToAvoidBottomInset: false,
      floatingWidget: Padding(
        padding: const EdgeInsets.all(25),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.iconAccent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              getIt.get<AppRouter>().push(const LogsRoute());
            },
            color: Colors.white,
            icon: const Icon(Icons.developer_board),
          ),
        ),
      ),
    );
  }
}
