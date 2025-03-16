enum MealType { breakfast, lunch, dinner }

class Meal {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isVeg;
  final MealType type;
  final String imageUrl;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isVeg,
    required this.type,
    required this.imageUrl,
  });
}
