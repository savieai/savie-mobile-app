import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../application/application.dart';
import '../presentation.dart';
import '../router/app_router.gr.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    Future<void>.delayed(const Duration(milliseconds: 750), () {
      getIt.get<AppRouter>().replaceAll(
        <PageRouteInfo>[const AuthWrapperFlowRoute()],
      );
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInToLinear,
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFB5012),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/splash.png',
            fit: BoxFit.fitWidth,
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              return Transform.scale(
                scale: _animation.value * 10,
                child: SvgPicture.asset(
                  'assets/splash_foreground.svg',
                  fit: BoxFit.fitWidth,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
