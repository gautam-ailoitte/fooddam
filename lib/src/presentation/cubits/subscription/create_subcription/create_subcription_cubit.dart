// lib/src/presentation/cubits/subscription/create_subscription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/usecase/subscription/create_subscription_usecase.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';

class CreateSubscriptionCubit extends Cubit<CreateSubscriptionState> {
  final CreateSubscriptionUseCase _createSubscriptionUseCase;
  final LoggerService _logger = LoggerService();

  // Stage tracking for subscription creation flow
  int _currentStage = 0;
  static const int PACKAGE_SELECTION_STAGE = 0;
  static const int MEAL_DISTRIBUTION_STAGE = 1;
  static const int ADDRESS_SELECTION_STAGE = 2;
  static const int SUMMARY_STAGE = 3;

  // Store the data as we progress through stages
  String? _packageId;
  List<MealDistribution>? _mealDistributions;
  String? _addressId;
  int _personCount = 1;
  String? _instructions;

  CreateSubscriptionCubit({
    required CreateSubscriptionUseCase createSubscriptionUseCase,
  }) : 
    _createSubscriptionUseCase = createSubscriptionUseCase,
    super(CreateSubscriptionInitial());

  // Move to the next stage of the flow
  void nextStage() {
    if (_currentStage < SUMMARY_STAGE) {
      _currentStage++;
      _emitCurrentStage();
    }
  }

  // Move to the previous stage
  void previousStage() {
    if (_currentStage > PACKAGE_SELECTION_STAGE) {
      _currentStage--;
      _emitCurrentStage();
    }
  }

  // Go to a specific stage (if valid)
  void goToStage(int stage) {
    if (stage >= PACKAGE_SELECTION_STAGE && stage <= SUMMARY_STAGE) {
      _currentStage = stage;
      _emitCurrentStage();
    }
  }

  // Helper to emit the current stage state
  void _emitCurrentStage() {
    switch (_currentStage) {
      case PACKAGE_SELECTION_STAGE:
        emit(PackageSelectionStage(selectedPackageId: _packageId));
        break;
      case MEAL_DISTRIBUTION_STAGE:
        if (_packageId == null) {
          emit(CreateSubscriptionError('Please select a package first'));
          _currentStage = PACKAGE_SELECTION_STAGE;
          emit(PackageSelectionStage());
        } else {
          emit(MealDistributionStage(
            packageId: _packageId!,
            mealDistributions: _mealDistributions,
            personCount: _personCount
          ));
        }
        break;
      case ADDRESS_SELECTION_STAGE:
        if (_mealDistributions == null || _mealDistributions!.isEmpty) {
          emit(CreateSubscriptionError('Please select at least one meal'));
          _currentStage = MEAL_DISTRIBUTION_STAGE;
          emit(MealDistributionStage(
            packageId: _packageId!,
            personCount: _personCount
          ));
        } else {
          emit(AddressSelectionStage(selectedAddressId: _addressId));
        }
        break;
      case SUMMARY_STAGE:
        if (_addressId == null) {
          emit(CreateSubscriptionError('Please select a delivery address'));
          _currentStage = ADDRESS_SELECTION_STAGE;
          emit(AddressSelectionStage());
        } else {
          emit(SubscriptionSummaryStage(
            packageId: _packageId!,
            mealDistributions: _mealDistributions!,
            addressId: _addressId!,
            personCount: _personCount,
            instructions: _instructions
          ));
        }
        break;
    }
  }

  // Set the selected package
  void selectPackage(String packageId) {
    _packageId = packageId;
    emit(PackageSelectionStage(selectedPackageId: packageId));
  }

  // Set the meal distributions
  void setMealDistributions(List<MealDistribution> distributions, int personCount) {
    _mealDistributions = distributions;
    _personCount = personCount;
    
    if (_currentStage == MEAL_DISTRIBUTION_STAGE) {
      emit(MealDistributionStage(
        packageId: _packageId!,
        mealDistributions: distributions,
        personCount: personCount
      ));
    }
  }

  // Set the delivery address
  void selectAddress(String addressId) {
    _addressId = addressId;
    
    if (_currentStage == ADDRESS_SELECTION_STAGE) {
      emit(AddressSelectionStage(selectedAddressId: addressId));
    }
  }

  // Set delivery instructions
  void setInstructions(String? instructions) {
    _instructions = instructions;
    
    if (_currentStage == SUMMARY_STAGE) {
      emit(SubscriptionSummaryStage(
        packageId: _packageId!,
        mealDistributions: _mealDistributions!,
        addressId: _addressId!,
        personCount: _personCount,
        instructions: instructions
      ));
    }
  }

  // Create the subscription with all collected data
  Future<void> createSubscription() async {
    if (_packageId == null || 
        _mealDistributions == null || 
        _mealDistributions!.isEmpty ||
        _addressId == null) {
      emit(CreateSubscriptionError('Missing required information for subscription'));
      return;
    }
    
    emit(CreateSubscriptionLoading());
    
    // Convert meal distributions to slots format expected by the API
    final slots = _mealDistributions!.map((md) => {
      'day': md.day.toLowerCase(),
      'timing': md.mealTime.toLowerCase(),
      'meal': md.mealId!,
    }).toList();
    
    final params = CreateSubscriptionParams(
      packageId: _packageId!,
      startDate: DateTime.now(),
      durationDays: 7, // Weekly subscription
      addressId: _addressId!,
      instructions: _instructions,
      slots: slots,
      personCount: _personCount,
    );
    
    final result = await _createSubscriptionUseCase(params);
    
    result.fold(
      (failure) {
        _logger.e('Failed to create subscription', error: failure);
        emit(CreateSubscriptionError('Failed to create subscription. Please try again.'));
      },
      (subscription) {
        _logger.i('Subscription created successfully: ${subscription.id}');
        emit(CreateSubscriptionSuccess(subscription: subscription));
      },
    );
  }
  
  // Reset all state and start over
  void resetState() {
    _currentStage = PACKAGE_SELECTION_STAGE;
    _packageId = null;
    _mealDistributions = null;
    _addressId = null;
    _personCount = 1;
    _instructions = null;
    emit(CreateSubscriptionInitial());
  }
}