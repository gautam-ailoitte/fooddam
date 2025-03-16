//  lib/core/validation/form_field_validators.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/validation/form_validarot.dart';

/// Common form field validators
class FieldValidators {
  /// Required field validator
  static FormFieldValidator<String> required({String? message}) {
    return (value) => FormValidator.required(value, message: message);
  }
  
  /// Email field validator
  static FormFieldValidator<String> email({bool required = true, String? message}) {
    return (value) {
      if (required) {
        final requiredError = FormValidator.required(value);
        if (requiredError != null) {
          return requiredError;
        }
      }
      return FormValidator.email(value, message: message);
    };
  }
  
  /// Password field validator
  static FormFieldValidator<String> password({
    bool required = true,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
    int minLength = 8,
    String? message,
  }) {
    return (value) {
      if (required) {
        final requiredError = FormValidator.required(value);
        if (requiredError != null) {
          return requiredError;
        }
      }
      
      return FormValidator.password(
        value,
        requireUppercase: requireUppercase,
        requireLowercase: requireLowercase,
        requireNumbers: requireNumbers,
        requireSpecialChars: requireSpecialChars,
        minLength: minLength,
        message: message,
      );
    };
  }
  
  /// Phone field validator
  static FormFieldValidator<String> phone({bool required = true, String? message}) {
    return (value) {
      if (required) {
        final requiredError = FormValidator.required(value);
        if (requiredError != null) {
          return requiredError;
        }
      }
      
      return FormValidator.phone(value, message: message);
    };
  }
  
  /// Name field validator
  static FormFieldValidator<String> name({bool required = true, String? message}) {
    return (value) {
      if (required) {
        final requiredError = FormValidator.required(value);
        if (requiredError != null) {
          return requiredError;
        }
      }
      
      if (value != null && value.isNotEmpty) {
        if (value.length < 2) {
          return message ?? 'Name must be at least 2 characters';
        }
        
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
          return message ?? 'Name should contain only letters';
        }
      }
      
      return null;
    };
  }
  
  /// Custom validator with optional requirement
  static FormFieldValidator<String> custom({
    bool required = true,
    required FormFieldValidator<String> validator,
  }) {
    return (value) {
      if (required) {
        final requiredError = FormValidator.required(value);
        if (requiredError != null) {
          return requiredError;
        }
      }
      
      return validator(value);
    };
  }
}

// lib/core/validation/form_controller.dart
