import '../../utils/string_extension.dart';

class SelectionInputModel<T> {
  final String? Function(T?)? validator;
  T? _selectedValue;
  String? errorMessage;

  SelectionInputModel({this.validator});

  bool validate() {
    errorMessage = validator?.call(_selectedValue);
    return errorMessage.isNullOrEmpty;
  }

  T? get selectedValue => _selectedValue;
  set selectedValue(T? value) {
    errorMessage = null;
    _selectedValue = value;
  }

  void clear() {
    selectedValue = null;
  }
}
