import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class ThaliCard extends StatelessWidget {
  final Thali thali;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onCustomize;

  const ThaliCard({
    super.key,
    required this.thali,
    required this.isSelected,
    required this.onSelect,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getThaliColor(thali.type),
                  ),
                ),
              ),
              SizedBox(height: 12),
              
              // Default meals list
              Text(
                'Includes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              ...thali.defaultMeals.map((meal) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      meal.isVeg ? Icons.eco : Icons.restaurant,
                      color: meal.isVeg ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        meal.name,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
              SizedBox(height: 12),
              
              // Price and customize button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${thali.basePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onCustomize,
                    icon: Icon(Icons.edit),
                    label: Text('Customize'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
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

  Color _getThaliColor(ThaliType type) {
    switch (type) {
      case ThaliType.normal:
        return Colors.green;
      case ThaliType.nonVeg:
        return Colors.red;
      case ThaliType.deluxe:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
