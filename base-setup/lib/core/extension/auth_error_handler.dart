class AuthErrorHandler {
  Error? error;

  AuthErrorHandler({
    this.error,
  });

  AuthErrorHandler.fromJson(Map<String, dynamic> json) {
    error = json['error'];
  }
}

class Error {
  List<String>? errors;
  List<dynamic>? errorParams;
  int? code;
  String? type;

  Error({
    this.errors,
    this.errorParams,
    this.code,
    this.type,
  });

  Error.fromJson(Map<String, dynamic> json) {
    errors = json['errors'];
    errorParams = json['errorParams'];
    code = json['code'];
    type = json['type'];
  }
}
