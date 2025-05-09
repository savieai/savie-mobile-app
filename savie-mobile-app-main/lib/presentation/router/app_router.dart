import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../presentation.dart';
import 'app_router.gr.dart';
export 'router_builders.dart';

@Singleton()
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(
          initial: true,
          page: SplashRoute.page,
        ),
        CustomRoute<dynamic>(
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 500,
          page: AuthWrapperFlowRoute.page,
          children: <AutoRoute>[
            _appFlow,
            _onboardingFlow,
          ],
        ),
        AutoRoute(page: LogsRoute.page),
      ];

  late final AutoRoute _appFlow = AutoRoute(
    page: InviteWrapperFlowRoute.page,
    children: <AutoRoute>[
      AutoRoute(
        page: AppFlowRoute.page,
        children: <AutoRoute>[
          _chatFlow,
          AutoRoute(
            page: SearchRoute.page,
          ),
          CustomRoute<dynamic>(
            page: ProfileRoute.page,
            customRouteBuilder: RouteBuilders.materialWithModalsBuilder,
          ),
          CustomRoute<dynamic>(
            page: CalendarRoute.page,
            customRouteBuilder: RouteBuilders.modalBottomSheet,
          ),
          CustomRoute<dynamic>(
            customRouteBuilder: RouteBuilders.modalPopupSheet,
            page: GetInviteRoute.page,
          ),
          CustomRoute<dynamic>(
            customRouteBuilder: RouteBuilders.modalPopupSheet,
            page: ProComingSoonRoute.page,
          ),
          CustomRoute<dynamic>(
            page: PhotoCarouselRoute.page,
            fullscreenDialog: true,
            opaque: false,
            barrierColor: Colors.transparent,
          ),
        ],
      ),
      AutoRoute(page: EnterReferralCodeRoute.page),
    ],
  );

  final AutoRoute _chatFlow = AutoRoute(
    initial: true,
    page: EmptyRoute.page,
    children: <AutoRoute>[
      CustomRoute<dynamic>(
        initial: true,
        page: ChatRoute.page,
        customRouteBuilder: RouteBuilders.materialWithModalsBuilder,
      ),
      CustomRoute<dynamic>(
        page: CameraRollRoute.page,
        customRouteBuilder: RouteBuilders.modalBottomSheet,
      ),
    ],
  );

  final AutoRoute _onboardingFlow = AutoRoute(
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
  );
}
