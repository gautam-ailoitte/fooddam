// lib/features/packages/widgets/package_filter.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';

class PackageFilter extends StatelessWidget {
  final String? currentFilter;
  final bool sortByPriceAsc;
  final Function(String?) onFilterSelected;
  final VoidCallback onSortToggled;
  
  const PackageFilter({
    super.key,
    required this.currentFilter,
    required this.sortByPriceAsc,
    required this.onFilterSelected,
    required this.onSortToggled,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.marginSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.marginMedium,
            ),
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  label: 'All',
                  value: null,
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'Vegetarian',
                  value: 'vegetarian',
                  icon: Icons.eco_outlined,
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'Non-Veg',
                  value: 'non-vegetarian',
                  icon: Icons.restaurant_outlined,
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'Premium',
                  value: 'premium',
                  icon: Icons.star_outline,
                ),
              ],
            ),
          ),
          
          // Sort button
          Padding(
            padding: EdgeInsets.only(
              left: AppDimensions.marginMedium,
              right: AppDimensions.marginMedium,
              top: AppDimensions.marginSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onSortToggled,
                  icon: Icon(
                    sortByPriceAsc
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                  ),
                  label: Text('Price ${sortByPriceAsc ? 'Low to High' : 'High to Low'}'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary, padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.marginSmall,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String? value,
    IconData? icon,
  }) {
    final isSelected = currentFilter == value;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onFilterSelected(value),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 14,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.marginSmall,
        vertical: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Color(0xFFE0E0E0),
        ),
      ),
    );
  }
}