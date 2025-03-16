// lib/core/validation/form_validator.dart
import 'package:flutter/material.dart';

/// Utility class for form validation
class FormValidator {
  /// Validates that a field is not empty
  static String? required(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }
  
  /// Validates a minimum length for a field
  static String? minLength(String? value, int minLength, {String? message}) {
    if (value == null || value.isEmpty) {
      return null; // Let required validator handle this
    }
    if (value.length < minLength) {
      return message ?? 'Must be at least $minLength characters';
    }
    return null;
  }
  
  /// Validates a maximum length for a field
  static String? maxLength(String? value, int maxLength, {String? message}) {
    if (value == null || value.isEmpty) {
      return null; // Let required validator handle this
    }
    if (value.length > maxLength) {
      return message ?? 'Must be at most $maxLength characters';
    }
    return null;
  }
  
  /// Validates an email address format
  static String? email(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return null; // Let required validator handle this
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validates a phone number format
  static String? phone(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return null; // Let required validator handle this
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return message ?? 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
  
  /// Validates a number is within a range
  static String? numberRange(String? value, {double? min, double? max, String? message}) {
    if (value == null || value.isEmpty) {
      return null; // Let required validator handle this
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return message ?? 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return message ?? 'Value must be at most $max';
    }
    
    return null;
  }
  
  /// Validates a password strength
  static String? password(String? value, {
    bool requireUppercase = true, 
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
    int minLength = 8,
    String? message,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Let required validator handle this
    }
    
    final List<String> validationIssues = [];
    
    if (value.length < minLength) {
      validationIssues.add('be at least $minLength characters');
    }
    
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      validationIssues.add('include an uppercase letter');
    }
    
    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      validationIssues.add('include a lowercase letter');
    }
    
    if (requireNumbers && !value.contains(RegExp(r'[0-9]'))) {
      validationIssues.add('include a number');
    }
    
    if (requireSpecialChars && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      validationIssues.add('include a special character');
    }
    
    if (validationIssues.isNotEmpty) {
      if (message != null) {
        return message;
      }
      
      return 'Password must ${validationIssues.join(', ')}';
    }
    
    return null;
  }
  
  /// Validates that two fields match
  static String? matches(String? value, String? valueToMatch, {String? message}) {
    if (value == null || value.isEmpty || valueToMatch == null) {
      return null; // Let required validator handle this
    }
    
    if (value != valueToMatch) {
      return message ?? 'Fields do not match';
    }
    
    return null;
  }
  
  /// Combines multiple validators
  static String? combine(String? value, List<FormFieldValidator<String?>> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}

