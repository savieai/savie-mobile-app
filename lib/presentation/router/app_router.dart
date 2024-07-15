import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../presentation.dart';
import 'app_router.gr.dart';
import 'guard/guard.dart';
export 'router_builders.dart';

@Singleton()
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  AppRouter(this._onboardingGuard);

  final OnboardingGuard _onboardingGuard;

  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(
          initial: true,
          guards: <AutoRouteGuard>[_onboardingGuard],
          page: OnboardingdRoute.page,
        ),
        AutoRoute(
          page: EmptyRoute.page,
          children: <AutoRoute>[
            CustomRoute(
              page: ChatRoute.page,
              customRouteBuilder: RouteBuilders.materialWithModalsBuilder,
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
      ];
}
