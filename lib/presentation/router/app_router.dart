import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../presentation.dart';
import 'app_router.gr.dart';
export 'router_builders.dart';

@Singleton()
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        CustomRoute(
          initial: true,
          page: ChatRoute.page,
          customRouteBuilder: RouteBuilders.materialWithModalsBuilder,
        ),
        CustomRoute(
          page: CameraRollRoute.page,
          customRouteBuilder: RouteBuilders.modalBottomSheet,
        )
      ];
}
