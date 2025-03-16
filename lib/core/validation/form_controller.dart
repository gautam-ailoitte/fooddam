import 'package:flutter/material.dart';

/// Form controller to manage form validation and submission
class FormController {
  /// Global form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  /// Map of field controllers
  final Map<String, TextEditingController> _controllers = {};
  
  /// Map of focus nodes
  final Map<String, FocusNode> _focusNodes = {};
  
  /// Create or get a text controller for a field
  TextEditingController controller(String field, {String? initialValue}) {
    if (!_controllers.containsKey(field)) {
      _controllers[field] = TextEditingController(text: initialValue);
    }
    return _controllers[field]!;
  }
  
  /// Create or get a focus node for a field
  FocusNode focusNode(String field) {
    if (!_focusNodes.containsKey(field)) {
      _focusNodes[field] = FocusNode();
    }
    return _focusNodes[field]!;
  }
  
  /// Get the current value of a field
  String? getValue(String field) {
    return _controllers[field]?.text;
  }
  
  /// Set the value of a field
  void setValue(String field, String value) {
    if (_controllers.containsKey(field)) {
      _controllers[field]!.text = value;
    }
  }
  
  /// Focus a specific field
  void focus(String field) {
    if (_focusNodes.containsKey(field)) {
      _focusNodes[field]!.requestFocus();
    }
  }
  
  /// Move focus to the next field
  void nextField(String currentField, String nextField) {
    if (_focusNodes.containsKey(currentField) && 
        _focusNodes.containsKey(nextField)) {
      _focusNodes[currentField]!.unfocus();
      _focusNodes[nextField]!.requestFocus();
    }
  }
  
  /// Validate all fields in the form
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }
  
  /// Get all form values as a map
  Map<String, String> getValues() {
    final Map<String, String> values = {};
    _controllers.forEach((key, controller) {
      values[key] = controller.text;
    });
    return values;
  }
  
  /// Reset all form fields
  void reset() {
    _controllers.forEach((_, controller) {
      controller.clear();
    });
    formKey.currentState?.reset();
  }
  
  /// Dispose of all controllers and focus nodes
  void dispose() {
    _controllers.forEach((_, controller) {
      controller.dispose();
    });
    _focusNodes.forEach((_, focusNode) {
      focusNode.dispose();
    });
  }
}