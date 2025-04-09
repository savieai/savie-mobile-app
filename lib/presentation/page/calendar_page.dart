import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../../domain/domain.dart';
import '../presentation.dart';

@RoutePage()
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundPrimary,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: CustomAppBar.preferredHeight,
              child: CustomAppBar(
                middle: const Text(
                  'Calendar',
                  style: AppTextStyles.subheadMedium,
                ),
                leading: CustomIconButton(
                  svgGenImage: Assets.icons.arrowLeft24,
                  onTap: context.router.maybePop,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<bool>(
                stream: getIt.get<GoogleServicesRepository>().isConnectedStream,
                initialData: getIt.get<GoogleServicesRepository>().isConnected,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  final bool isConnected = snapshot.data ?? false;

                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 56),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (isConnected)
                          Assets.icons.calendarCheck.svg()
                        else
                          Assets.icons.calendarClock.svg(),
                        const SizedBox(height: 16),
                        Text(
                          isConnected
                              ? 'Calendar connected'
                              : 'No calendar connected',
                          style: AppTextStyles.subheadMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isConnected
                              ? 'danila@wonderwork.design'
                              : 'Connect your calendar so Savie\ncan turn notes into meetings',
                          style: AppTextStyles.paragraph.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton(
                          onPressed: () {
                            if (isConnected) {
                              getIt
                                  .get<GoogleServicesRepository>()
                                  .disconnect();
                            } else {
                              getIt.get<GoogleServicesRepository>().connect();
                            }
                          },
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? AppColors.iconNegative
                                  : AppColors.iconAccent,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (isConnected)
                                  Assets.icons.calenderRemove.svg()
                                else
                                  Assets.icons.calenderAdd.svg(),
                                const SizedBox(width: 8),
                                Text(
                                  isConnected
                                      ? 'Disconnect'
                                      : 'Connect calendar',
                                  style: AppTextStyles.footnote.copyWith(
                                    color: AppColors.textInvert,
                                    height: 18 / 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
