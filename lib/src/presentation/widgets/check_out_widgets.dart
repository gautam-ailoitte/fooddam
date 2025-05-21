// lib/features/checkout/widgets/address_selection_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class AddressSelectionCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback? onEdit;

  const AddressSelectionCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelected,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected ? true : null,
                onChanged: (_) => onSelected(),
                activeColor: AppColors.primary,
              ),
              SizedBox(width: AppDimensions.marginSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${address.street}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${address.city}, ${address.state} ${address.zipCode}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.textSecondary),
                  onPressed: onEdit,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutSummaryCard extends StatelessWidget {
  final Package package;
  final List<MealSlot> mealSlots;
  final int personCount;

  const CheckoutSummaryCard({
    super.key,
    required this.package,
    required this.mealSlots,
    required this.personCount,
  });

  @override
  Widget build(BuildContext context) {
    // Count meals by type
    final Map<String, int> mealCountByType = {
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
    };

    for (final slot in mealSlots) {
      final type = slot.timing.toLowerCase();
      if (mealCountByType.containsKey(type)) {
        mealCountByType[type] = (mealCountByType[type] ?? 0) + 1;
      }
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package name and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    package.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  "todo", // '₹${(package.price * personCount).toStringAsFixed(0)}', todo
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              package.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Divider(),
            SizedBox(height: AppDimensions.marginSmall),

            // Meal count breakdown
            Text(
              'Meal Selection:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppDimensions.marginSmall),

            // Breakfast count
            _buildMealCountRow(
              context,
              'Breakfast',
              mealCountByType['breakfast'] ?? 0,
              Icons.free_breakfast,
            ),
            SizedBox(height: AppDimensions.marginSmall),

            // Lunch count
            _buildMealCountRow(
              context,
              'Lunch',
              mealCountByType['lunch'] ?? 0,
              Icons.lunch_dining,
            ),
            SizedBox(height: AppDimensions.marginSmall),

            // Dinner count
            _buildMealCountRow(
              context,
              'Dinner',
              mealCountByType['dinner'] ?? 0,
              Icons.dinner_dining,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Divider(),
            SizedBox(height: AppDimensions.marginSmall),

            // Person count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Number of People:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$personCount',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginSmall),

            // Total meals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Meals:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${mealSlots.length * personCount}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginSmall),

            // Price calculation
            if (personCount > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price Calculation:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'todo', //todo: // '₹${package.price.toStringAsFixed(0)} × $personCount',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCountRow(
    BuildContext context,
    String mealType,
    int count,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        SizedBox(width: AppDimensions.marginSmall),
        Text('$mealType:', style: Theme.of(context).textTheme.bodyMedium),
        Spacer(),
        Text(
          '$count meal${count != 1 ? 's' : ''}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class DeliveryInstructionsField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const DeliveryInstructionsField({
    Key? key,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Special Instructions for Delivery',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Add any special instructions for the delivery person',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            TextFormField(
              initialValue: value,
              onChanged: onChanged,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Ring the bell, call when at gate, etc.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
