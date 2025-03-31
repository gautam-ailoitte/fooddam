// lib/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_state.dart';

class CreateSubscriptionCubit extends Cubit<CreateSubscriptionState> {
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  // Simple data storage - no stages
  String? _packageId;
  List<MealSlot>? _mealSlots;
  String? _addressId;
  int _personCount = 1;
  String? _instructions;
  DateTime _startDate = DateTime.now().add(Duration(days: 1));
  int _durationDays = 7;

  CreateSubscriptionCubit({
    required SubscriptionUseCase subscriptionUseCase,
  }) : 
    _subscriptionUseCase = subscriptionUseCase,
    super(CreateSubscriptionInitial());

  // Set the selected package
  void selectPackage(String packageId) {
    _packageId = packageId;
    emit(DataUpdated()); // Simple state to indicate data was updated
  }

  // Set subscription details like start date and duration
  void setSubscriptionDetails({DateTime? startDate, int? durationDays}) {
    if (startDate != null) {
      _startDate = startDate;
    }
    
    if (durationDays != null) {
      _durationDays = durationDays;
    }
    
    emit(DataUpdated());
  }

  // Set the meal distributions
  void setMealDistributions(
    List<MealSlot> slots,
    int personCount,
  ) {
    _mealSlots = slots;
    _personCount = personCount;
    emit(DataUpdated());
  }

  // Set the delivery address
  void selectAddress(String addressId) {
    _addressId = addressId;
    emit(DataUpdated());
  }

  // Set delivery instructions
  void setInstructions(String? instructions) {
    _instructions = instructions;
    emit(DataUpdated());
  }

  // Create the subscription with all collected data
 Future<void> createSubscription() async {
  // Validate required data is present
  if (_packageId == null ||
      _mealSlots == null ||
      _mealSlots!.isEmpty ||
      _addressId == null) {
    emit(
      CreateSubscriptionError(
        'Missing required information for subscription',
      ),
    );
    return;
  }
  
  emit(CreateSubscriptionLoading());
  
  // Create slots with preserved mealId for the API
  final slots = _mealSlots!.map((slot) => 
    MealSlot(
      day: slot.day,
      timing: slot.timing,
    )
  ).toList();
  
  final params = SubscriptionParams(
    packageId: _packageId!,
    startDate: _startDate,
    durationDays: _durationDays,
    addressId: _addressId!,
    instructions: _instructions,
    slots: slots,
    personCount: _personCount, // For UI only
  );
  
  final result = await _subscriptionUseCase.createSubscription(params);
  
  result.fold(
    (failure) {
      _logger.e('Failed to create subscription', error: failure);
      emit(
        CreateSubscriptionError(
          'Failed to create subscription: ${failure.message}',
        ),
      );
    },
    (successMessage) {
      _logger.i('Subscription created successfully with message: $successMessage');
      emit(CreateSubscriptionSuccess(message: successMessage));
    },
  );
}
  // Reset all state and start over
  void resetState() {
    _packageId = null;
    _mealSlots = null;
    _addressId = null;
    _personCount = 1;
    _instructions = null;
    _startDate = DateTime.now().add(Duration(days: 1));
    _durationDays = 7;
    emit(CreateSubscriptionInitial());
  }
}