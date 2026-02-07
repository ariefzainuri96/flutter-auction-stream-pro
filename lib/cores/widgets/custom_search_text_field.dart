import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_theme.dart';

class CustomSearchTextField extends StatelessWidget {
  final String hint;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function(String)? onSubmit;

  const CustomSearchTextField({
    super.key,
    required this.hint,
    this.onChanged,
    this.focusNode,
    this.controller,
    this.onSubmit,
  });

  InputBorder getBorder(Color color) => UnderlineInputBorder(
        borderSide: BorderSide(
          width: 1.0,
          color: color,
        ),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48.0,
        child: TextFormField(
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          controller: controller,
          onChanged: (value) => onChanged?.call(value.trim()),
          maxLines: 1,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 16.0),
            hintText: hint,
            hintStyle: textTheme.font16Reguler.copyWith(color: colors.grey3),
            border: getBorder(colors.font),
            counterStyle: textTheme.font12Reguler.copyWith(fontSize: 10.0),
            enabledBorder: getBorder(colors.font),
            disabledBorder: getBorder(colors.disable),
            focusedBorder: getBorder(colors.font),
            // errorBorder: getBorder(colors.lightGrey),
            focusedErrorBorder: getBorder(colors.red1),
          ),
          style: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return textTheme.font16Reguler.copyWith(color: colors.grey3);
            }
            return textTheme.font16Reguler;
          }),
          onFieldSubmitted: onSubmit,
        ),
      );
}
