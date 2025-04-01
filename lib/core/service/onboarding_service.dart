// lib/core/service/onboarding_service.dart
import 'package:injectable/injectable.dart';
import 'package:foodam/core/service/storage_service.dart';

@injectable
class OnboardingService {
  final StorageService _storageService;
  static const String _onboardingCompletedKey = 'ONBOARDING_COMPLETED';

  OnboardingService(this._storageService);

  Future<bool> isOnboardingCompleted() async {
    return _storageService.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _storageService.setBool(_onboardingCompletedKey, completed);
  }

  Future<void> markOnboardingCompleted() async {
    await setOnboardingCompleted(true);
  }

  Future<void> resetOnboarding() async {
    await setOnboardingCompleted(false);
  }
}