import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@injectable
class CompleteOnboardingUseCase {
  CompleteOnboardingUseCase(this._onboardingRepository);

  final OnboardingRepository _onboardingRepository;

  Future<void> execute() => _onboardingRepository.setOnboardingPassed();
}
