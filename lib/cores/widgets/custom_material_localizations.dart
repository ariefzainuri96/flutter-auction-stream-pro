import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomMaterialLocalizations extends DefaultMaterialLocalizations {
  @override
  String get okButtonLabel => 'SET DATE';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get datePickerHelpText => ''; // removes "Select date"

  @override
  String formatMediumDate(DateTime date) => '';
}

class CustomMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const CustomMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(CustomMaterialLocalizations());

  @override
  bool shouldReload(LocalizationsDelegate<MaterialLocalizations> old) => false;
}
