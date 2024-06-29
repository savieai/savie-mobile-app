import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';
import '../app_router.gr.dart';

@Singleton()
class OnboardingGuard extends AutoRouteGuard {
  OnboardingGuard(this._onboardingRepository);

  final OnboardingRepository _onboardingRepository;

  @override
  void onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) {
    if (_onboardingRepository.onboardingPassed) {
      router.push(const ChatRoute());
      return;
    }

    resolver.next();
  }
}
