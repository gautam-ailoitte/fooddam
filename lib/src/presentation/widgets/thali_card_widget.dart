// lib/src/presentation/widgets/thali_card_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_text_style.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/presentation/helpers/thali_selection_helper.dart';
import 'package:foodam/src/presentation/utlis/price_formatter_utility.dart';

class ThaliCard extends StatelessWidget {
  final Thali thali;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onCustomize;
  final LoggerService _logger = LoggerService();

  ThaliCard({
    super.key,
    required this.thali,
    required this.isSelected,
    required this.onSelect,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    _logger.d('Building ThaliCard for ${thali.name}', tag: 'WIDGET');

    return Card(
      elevation: isSelected ? 4 : 2,
      margin: EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: _handleSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thali type badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getThaliColor(thali.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  thali.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getThaliColor(thali.type),
                  ),
                ),
              ),
              AppSpacing.vMd,

              // Default meals list
              Text(StringConstants.includes, style: AppTextStyles.labelLarge),
              AppSpacing.vSm,
              ...thali.defaultMeals.map(
                (meal) => Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        meal.isVeg ? Icons.eco : Icons.restaurant,
                        color:
                            meal.isVeg
                                ? AppColors.vegetarian
                                : AppColors.nonVegetarian,
                        size: 16,
                      ),
                      AppSpacing.hSm,
                      Expanded(
                        child: Text(meal.name, style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.vMd,

              // Price and customize button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PriceFormatter.formatPrice(thali.basePrice),
                    style: AppTextStyles.priceLarge,
                  ),
                  TextButton.icon(
                    onPressed: _handleCustomize,
                    icon: Icon(Icons.edit),
                    label: Text(StringConstants.customize),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSelect() {
    _logger.d('ThaliCard selected: ${thali.name}', tag: 'WIDGET');
    onSelect();
  }

  void _handleCustomize() {
    _logger.d('ThaliCard customize clicked: ${thali.name}', tag: 'WIDGET');
    onCustomize();
  }

  Color _getThaliColor(ThaliType type) {
    return ThaliSelectionHelper.getThaliColor(type);
  }
}
