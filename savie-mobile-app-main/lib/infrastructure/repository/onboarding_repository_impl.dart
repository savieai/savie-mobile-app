import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/domain.dart';

enum _OnboardingKeys {
  onboardingPassed('onboardingPassed');

  const _OnboardingKeys(this.key);

  final String key;
}

@Injectable(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._sharedPreferences);
  final SharedPreferences _sharedPreferences;

  @override
  bool get onboardingPassed =>
      _sharedPreferences.getBool(_OnboardingKeys.onboardingPassed.key) ?? false;

  @override
  Future<void> setOnboardingPassed() =>
      _sharedPreferences.setBool(_OnboardingKeys.onboardingPassed.key, true);
}
