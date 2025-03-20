// lib/src/presentation/utils/form_validator.dart
class FormValidator {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }
  
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    if (value.length != 10 || !_isNumeric(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    
    return null;
  }
  
  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 5) {
      return 'Please enter a complete address';
    }
    
    return null;
  }
  
  String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    
    return null;
  }
  
  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }
    
    return null;
  }
  
  String? validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'ZIP code is required';
    }
    
    if (value.length != 6 || !_isNumeric(value)) {
      return 'Please enter a valid 6-digit ZIP code';
    }
    
    return null;
  }
  
  String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) {
      return 'Start date is required';
    }
    
    if (endDate == null) {
      return 'End date is required';
    }
    
    if (startDate.isAfter(endDate)) {
      return 'Start date cannot be after end date';
    }
    
    return null;
  }
  
  bool _isNumeric(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }
}