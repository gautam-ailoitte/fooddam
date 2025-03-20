// lib/src/presentation/utils/price_calculator.dart

class PriceCalculator {
  double calculateTotalPrice(double basePrice, double? customizationCharges, double? discount) {
    var total = basePrice;
    
    if (customizationCharges != null) {
      total += customizationCharges;
    }
    
    if (discount != null) {
      total -= discount;
    }
    
    return _roundTo2Decimals(total);
  }
  
  double calculateDailyPrice(Map<String, double> mealPrices) {
    double total = 0;
    
    mealPrices.forEach((_, price) {
      total += price;
    });
    
    return _roundTo2Decimals(total);
  }
  
  double calculatePlanPrice(double dailyPrice, int days) {
    return _roundTo2Decimals(dailyPrice * days);
  }
  
  double calculateTax(double amount, double taxRate) {
    return _roundTo2Decimals(amount * (taxRate / 100));
  }
  
  double calculateDiscount(double amount, double discountPercentage) {
    return _roundTo2Decimals(amount * (discountPercentage / 100));
  }
  
  double calculateMealTypeTotal(List<String> selectedDays, double pricePerDay) {
    return _roundTo2Decimals(selectedDays.length * pricePerDay);
  }
  
  double calculateCustomizationCharges(Map<String, int> customizations, Map<String, double> prices) {
    double total = 0;
    
    customizations.forEach((item, quantity) {
      if (prices.containsKey(item)) {
        total += prices[item]! * quantity;
      }
    });
    
    return _roundTo2Decimals(total);
  }
  
  // Format price as string with currency symbol
  String formatPrice(double price, {String currencySymbol = '₹'}) {
    return '$currencySymbol${price.toStringAsFixed(2)}';
  }
  
  double _roundTo2Decimals(double value) {
    return (value * 100).round() / 100;
  }
}