// lib/src/presentation/cubits/subscription/create_subscription_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

abstract class CreateSubscriptionState extends Equatable {
  const CreateSubscriptionState();
  
  @override
  List<Object?> get props => [];
}

class CreateSubscriptionInitial extends CreateSubscriptionState {}

class CreateSubscriptionLoading extends CreateSubscriptionState {}

// States for the multi-stage subscription flow
class PackageSelectionStage extends CreateSubscriptionState {
  final String? selectedPackageId;
  
  const PackageSelectionStage({this.selectedPackageId});
  
  @override
  List<Object?> get props => [selectedPackageId];
  
  bool get hasPackageSelected => selectedPackageId != null;
}

class MealDistributionStage extends CreateSubscriptionState {
  final String packageId;
  final List<MealSlot>? mealDistributions;
  final int personCount;
  
  const MealDistributionStage({
    required this.packageId,
    this.mealDistributions,
    this.personCount = 1,
  });
  
  @override
  List<Object?> get props => [packageId, mealDistributions, personCount];
  
  bool get hasMealsSelected => mealDistributions != null && mealDistributions!.isNotEmpty;
  
  int get totalMeals => (mealDistributions?.length ?? 0) * personCount;
}

class AddressSelectionStage extends CreateSubscriptionState {
  final String? selectedAddressId;
  
  const AddressSelectionStage({this.selectedAddressId});
  
  @override
  List<Object?> get props => [selectedAddressId];
  
  bool get hasAddressSelected => selectedAddressId != null;
}

class SubscriptionSummaryStage extends CreateSubscriptionState {
  final String packageId;
  final List<MealSlot> mealDistributions;
  final String addressId;
  final int personCount;
  final String? instructions;
  
  const SubscriptionSummaryStage({
    required this.packageId,
    required this.mealDistributions,
    required this.addressId,
    required this.personCount,
    this.instructions,
  });
  
  @override
  List<Object?> get props => [
    packageId, 
    mealDistributions, 
    addressId, 
    personCount,
    instructions
  ];
}

class CreateSubscriptionSuccess extends CreateSubscriptionState {
  final Subscription subscription;
  
  const CreateSubscriptionSuccess({required this.subscription});
  
  @override
  List<Object?> get props => [subscription];
}

class CreateSubscriptionError extends CreateSubscriptionState {
  final String message;
  
  const CreateSubscriptionError(this.message);
  
  @override
  List<Object?> get props => [message];
}