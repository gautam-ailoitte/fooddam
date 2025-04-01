import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Localization class for loading different languages
class AiloitteMyLocalizations {
  /// Getting instance of this class
  static AiloitteMyLocalizations of(BuildContext context) {
    return Localizations.of<AiloitteMyLocalizations>(
        context, AiloitteMyLocalizations)!;
  }

  /// Getting string from en.json
  String getString(String key) {
    return language!.containsKey(key) ? language![key] : "Build Again";
  }

  /// Getting list from en.json
  List<String> getList(String key) {
    final List<String> items = List.empty(growable: true);
    if (language![key] is List) {
      items.addAll(List<String>.from(language![key].whereType<String>()));
    }
    return items;
  }

  /// Getting Map list from en.json
  List<Map> getMapList(String key) {
    final List<Map> items = List.empty(growable: true);
    if (language![key] is List) {
      items.addAll(List<Map>.from(language![key].whereType<Map>()));
    }
    return items;
  }

  /// Getting HashMap from en.json
  dynamic getMap(String key) {
    return language![key];
  }
}

Map<String, dynamic>? language;

/// Class to load the json file for strings
class AiloitteMyLocalizationsDelegate
    extends LocalizationsDelegate<AiloitteMyLocalizations> {
  const AiloitteMyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AiloitteMyLocalizations> load(Locale locale) async {
    final String string =
        await rootBundle.loadString("asset/i18n/${locale.languageCode}.json");
    language = json.decode(string);
    return SynchronousFuture<AiloitteMyLocalizations>(
        AiloitteMyLocalizations());
  }

  @override
  bool shouldReload(AiloitteMyLocalizationsDelegate old) => false;
}
