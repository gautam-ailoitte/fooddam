// lib/src/domain/entities/package_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/package/package_image_entity.dart';
import 'package:foodam/src/domain/entities/package/package_slot_entity.dart';

class Package extends Equatable {
  final int index;
  final String id;
  final String name;
  final String description;
  final int week;
  final double totalPrice;
  final String dietaryPreference;
  final PackageImage? image;
  final int noOfSlots;
  final bool isActive;
  final List<PackageSlot> slots;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Package({
    required this.index,
    required this.id,
    required this.name,
    required this.description,
    required this.week,
    required this.totalPrice,
    required this.dietaryPreference,
    this.image,
    required this.noOfSlots,
    required this.isActive,
    this.slots = const [],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    index,
    id,
    name,
    description,
    week,
    totalPrice,
    dietaryPreference,
    image,
    noOfSlots,
    isActive,
    slots,
    createdAt,
    updatedAt,
  ];

  // Convenience getters
  bool get isVegetarian => dietaryPreference == 'vegetarian';
  bool get isNonVegetarian => dietaryPreference == 'non-vegetarian';
  bool get hasSlots => slots.isNotEmpty;
  String? get imageUrl => image?.url;

  String get priceDisplayText => '₹${totalPrice.toStringAsFixed(0)}';

  String get weekDisplayText => 'Week $week';

  String get dietaryDisplayText =>
      dietaryPreference == 'vegetarian' ? 'Vegetarian' : 'Non-Vegetarian';

  // Slot convenience methods
  PackageSlot? getSlotByDay(String day) {
    try {
      return slots.firstWhere(
        (slot) => slot.day.toLowerCase() == day.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<String> get availableDays {
    return slots.where((slot) => slot.hasMeal).map((slot) => slot.day).toList();
  }

  int get totalMealsInWeek {
    int count = 0;
    for (final slot in slots) {
      if (slot.hasMeal && slot.meal != null) {
        count += slot.meal!.mealCount;
      }
    }
    return count;
  }

  double get averageMealPrice {
    if (totalMealsInWeek == 0) return 0;
    return totalPrice / totalMealsInWeek;
  }

  // For backward compatibility with old price structure
  double get minPrice => totalPrice;
  double get maxPrice => totalPrice;
}
