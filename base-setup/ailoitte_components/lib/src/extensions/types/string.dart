import 'dart:developer';

import 'package:intl/intl.dart';

extension AiloitteStringExtensions on String {
  String get capitalizeFirstLetter {
    if (length == 0) return '';
    final firstLetter = this[0].toUpperCase();
    return '$firstLetter${substring(1).toLowerCase()}';
  }

  String get dateString {
    return DateFormat("dd-MM-yyyy").format(DateTime.parse(this));
  }

  String get capitalizeFirstLetterOfEveryWord {
    if (isEmpty) {
      return this;
    }

    final list = toLowerCase().split(' ');

    list.removeWhere((element) => element.trim().isEmpty);

    return list.map((word) {
      final String leftText =
          (word.length > 1) ? word.substring(1, word.length) : '';
      return word[0].toUpperCase() + leftText;
    }).join(' ');
  }

  String get convertingCamelToPascalCase {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String? isValidTitle(String? title) {
    return (title ?? '').trim().isEmpty
        ? null
        : isEmpty
            ? "Please Enter $title"
            : length < 1
                ? "Enter Proper $title"
                : null;
  }

  String get firstName {
    return split(" ").first;
  }

  String getValueWithComa({String operator = ','}) {
    return (this).isEmpty ? '' : '$this$operator';
  }

  String get lastName {
    return replaceAll(firstName, '').trim();
  }

  String get replaceSpecial {
    return replaceAll('[', '').replaceAll("]", '').trim();
  }

  String get replaceAllSpecial {
    return replaceAll(RegExp(r'[^\w\s]'), '');
  }

  String get replaceAllSpace {
    return replaceAll(' ', '');
  }

  String get addressLine1 {
    return split(
      "\n",
    ).first;
  }

  String get addressLine2 {
    return replaceAll(addressLine1, '').trim();
  }

  String get capitalize {
    return toUpperCase();
  }

  String get capitalizeFirstLetterOfSentence {
    return toBeginningOfSentenceCase(this) ?? '';
  }

  String get removeSpecialChar {
    return replaceAll(RegExp('[^A-Za-z0-9]'), ' ').trim();
  }

  String toErrorMessage(List<String> data) {
    final error = StringBuffer();
    for (final element in data) {
      ///Mayank : fix \n removed
      error.write(element);
    }
    if (error.toString().endsWith("\n")) {
      error.write(error.toString().substring(0, error.length - 1));
    }
    return error.toString();
  }

  String toErrorMessageFromMap(List<dynamic> data) {
    var error = "";
    for (final element in data) {
      if (element.containsKey("message")) {
        error += element["message"] + "\n";
      } else if (element.containsKey("msg")) {
        error += element["msg"] + "\n";
      }
    }
    if (error.endsWith("\n")) {
      error = error.substring(0, error.length - 1);
    }
    return error;
  }

  bool get isValidEmail {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }

  String? get isValidUrl {
    return RegExp(
      r'^((https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,}))',
    ).hasMatch(this)
        ? null
        : "Please Enter valid Url";
  }

  bool get checkValidUrl {
    final uri = Uri.tryParse(this);
    if (uri == null) {
      return false;
    }
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String? get isValidNonMandatoryUrl {
    if (isEmpty) return null;
    return RegExp(
      r'^((https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,}))',
    ).hasMatch(this)
        ? null
        : "Please Enter validUrl";
  }

  String? get isValidTwitterUrl {
    if (isEmpty) return null;
    return RegExp(
                r"(?:http:\/\/)?(?:www\.)?twitter\.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[\w\-]*\/)*([\w\-]*)")
            .hasMatch(this)
        ? null
        : "Please Enter valid Twitter Url";
  }

  String? get isValidFacebookUrl {
    if (isEmpty) return null;
    return RegExp(
                r"(?:(?:http|https):\/\/)?(?:www.)?facebook.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\-]*)?")
            .hasMatch(this)
        ? null
        : "Please Enter valid Facebook Url";
  }

  String? get isValidLinkedInUrl {
    if (isEmpty) return null;
    return RegExp(
                // r"((https?:\/\/)?((www|\w\w)\.)?linkedin\.com\/)((([\w]{2,3})?)|([^\/]+\/(([\w|\d-&#?=])+\/?){1,}))$")
                r"((https?:\/\/)?((www|\w\w)\.)?linkedin\.com\/)(((([\w|\d-&#?=])+\/?){1,}))$")
            .hasMatch(this)
        ? null
        : "Please Enter valid LinkedIn Url";
  }

  String? get isValidResearchGateUrl {
    if (isEmpty) return null;
    return RegExp(
      r'^((https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,}))',
    ).hasMatch(this)
        ? Uri.parse(this).host.contains("researchgate")
            ? null
            : "Please Enter valid Research Gate Url"
        : "Please Enter valid Research Gate Url";
  }

  bool get isValidMobileNumber {
    return length == 10 && isNumber;
  }

  bool get isNumber {
    return RegExp(r'^[1-9]\d*$').hasMatch(this);
  }

  bool isVideo(String mediaType) {
    return mediaType.contains("video");
  }

  String get sentenceCase {
    return replaceAll(RegExp(' +'), ' ')
        .split(" ")
        .map((str) => str.inCaps)
        .join(" ");
  }

  String get inCaps {
    return length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }

  String? nameInitial() {
    if (isEmpty) return null;
    final String lastChar = split(" ").last.capitalizeFirstLetter;
    return "${this[0]}${(lastChar).isNotEmpty ? lastChar[0] : ''}";
  }

  String? validatePinCode(String country) {
    return isEmpty
        ? "Enter Pin Code"
        : (country.isEmpty || country.toLowerCase().contains("ind")
                    ? RegExp(
                        "^[1-9][0-9]{5}\$",
                      )
                    : RegExp(
                        "^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*\$",
                      ))
                .hasMatch(this)
            ? null
            : "enterValidName";
  }

  bool get isIndia {
    return isEmpty || toLowerCase().contains("ind");
  }

  String? get validaName {
    return isEmpty
        ? "Enter First Name"
        : RegExp("^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*\$").hasMatch(trim())
            ? null
            : "Enter Valid Name";
  }

  String? get validaLastName {
    return isEmpty
        ? "Enter Last name"
        : RegExp("^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*\$").hasMatch(trim())
            ? null
            : "Enter Valid Lame";
  }

  String? get validaTitle {
    return isEmpty
        ? "entertitle"
        : RegExp("^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*\$").hasMatch(this)
            ? null
            : "enterValidTitle";
  }

  String? get validatePassword {
    final regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    final String passNonNullValue = trim();

    if (passNonNullValue.isEmpty) {
      return "Password is required";
    } else if (passNonNullValue.length < 8) {
      return "Password Must be more than 8 characters";
    } else if (!regex.hasMatch(passNonNullValue)) {
      return "Password should contain upper, lower, digit\n and Special characters";
    }
    return null;
  }

  bool get isValidIndianPinCode {
    final regex = RegExp('[1-9]{1}[0-9]{5}|[1-9]{1}[0-9]{3}\\s[0-9]{3}');
    print(regex.hasMatch(this));
    return regex.hasMatch(this);
  }

  bool get isNotEqualToNoDataFound {
    return this != "Data not found";
  }

  bool get isNotEmpty {
    return this.isNotEmpty;
  }

  String get publicIdFromCloudinaryUrl {
    final urlLastPart = split("/").last;

    log(urlLastPart.split(".")[0]);

    return "DEV_ASSETS/20230518_102910"; /* urlLastPart.split(".")[0];*/
  }
}
