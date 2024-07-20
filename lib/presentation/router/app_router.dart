import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../presentation.dart';
import 'app_router.gr.dart';
export 'router_builders.dart';

@Singleton()
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  AppRouter();

  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(
          page: AuthWrapperFlowRoute.page,
          initial: true,
          children: <AutoRoute>[
            AutoRoute(
              page: AppFlowRoute.page,
              children: <AutoRoute>[
                AutoRoute(
                  initial: true,
                  page: EmptyRoute.page,
                  children: <AutoRoute>[
                    CustomRoute(
                      initial: true,
                      page: ChatRoute.page,
                      customRouteBuilder:
                          RouteBuilders.materialWithModalsBuilder,
                    ),
                    CustomRoute(
                      page: CameraRollRoute.page,
                      customRouteBuilder: RouteBuilders.modalBottomSheet,
                    ),
                    CustomRoute(
                      page: PhotoCarouselRoute.page,
                      fullscreenDialog: true,
                      opaque: false,
                      barrierColor: Colors.transparent,
                    ),
                  ],
                ),
                AutoRoute(
                  page: SearchRoute.page,
                ),
                AutoRoute(
                  page: ProfileRoute.page,
                ),
              ],
            ),
            AutoRoute(
              page: OnboardingFlowRoute.page,
              children: <AutoRoute>[
                AutoRoute(
                  initial: true,
                  page: WelcomeRoute.page,
                ),
                AutoRoute(
                  page: OtpFlowRoute.page,
                  children: <AutoRoute>[
                    AutoRoute(
                      initial: true,
                      page: OtpSubmissionRoute.page,
                    ),
                    AutoRoute(
                      page: OtpConfirmationRoute.page,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ];
}
