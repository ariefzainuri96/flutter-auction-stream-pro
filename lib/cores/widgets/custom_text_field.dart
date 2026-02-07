import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/text_theme.dart';
import '../utils/string_extension.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final String hint;
  final bool obscureText;
  final String? Function(String)? validator;
  final void Function(String?)? onValidate;
  final Function(String)? onSubmit;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final bool hasError;
  final EdgeInsets? contentPadding;
  final Color? filledColor;
  final double? borderRadius;
  final double? height;
  final TextInputAction? inputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? labelText;
  final String? subLabelText;
  final bool showAsterisk;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool readOnly;
  final Function()? onFieldTap;
  final Color? defaultBorderColor;
  final double? defaultBorderWidth;
  final int? maxLength;
  final AutovalidateMode? autovalidateMode;
  final String? errorText;
  final bool nullHeight;
  final String? initialValue;

  CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.enabled = true,
    required this.hint,
    this.onSubmit,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.hasError = false,
    this.onValidate,
    this.onChanged,
    this.contentPadding,
    this.filledColor,
    this.borderRadius,
    this.height,
    this.inputAction,
    this.keyboardType,
    this.inputFormatters,
    this.labelText,
    this.subLabelText,
    this.showAsterisk = false,
    this.maxLines,
    this.minLines,
    this.expands = false,
    this.readOnly = false,
    this.onFieldTap,
    this.defaultBorderColor,
    this.defaultBorderWidth,
    this.maxLength,
    this.autovalidateMode,
    this.errorText,
    this.nullHeight = false,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool obscureText;

  @override
  void initState() {
    obscureText = widget.obscureText;
    super.initState();
  }

  bool get filled => widget.filledColor != null;

  InputBorder getBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(
          width: widget.defaultBorderWidth ?? 1.0,
          color: filled
              ? Colors.transparent
              : widget.hasError
                  ? colors.red1
                  : color,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
      );

  @override
  Widget build(BuildContext context) {
    final inputField = SizedBox(
      height: widget.expands || widget.nullHeight || widget.maxLines != null
          ? null
          : widget.height ?? 48.0,
      child: TextFormField(
        focusNode: widget.focusNode,
        textInputAction: widget.inputAction,
        enabled: widget.enabled,
        initialValue: widget.initialValue,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        controller: widget.controller,
        onChanged: (value) => widget.onChanged?.call(value.trim()),
        obscureText: obscureText,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines ?? (widget.expands ? null : 1),
        minLines: widget.minLines,
        expands: widget.expands,
        autovalidateMode: widget.autovalidateMode,
        decoration: InputDecoration(
          contentPadding: widget.contentPadding ??
              EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          hintText: widget.hint,
          hintStyle: textTheme.font16Reguler.copyWith(color: colors.grey3),
          filled: filled || !widget.enabled,
          fillColor: widget.filledColor ?? colors.grey2,
          border: getBorder(widget.defaultBorderColor ?? colors.grey2),
          counterStyle: textTheme.font12Reguler.copyWith(fontSize: 10.0),
          enabledBorder: getBorder(widget.defaultBorderColor ?? colors.grey2),
          disabledBorder: getBorder(colors.disable),
          focusedBorder: getBorder(colors.grey2),
          // errorBorder: getBorder(colors.lightGrey),
          focusedErrorBorder: getBorder(colors.red1),
          errorStyle: textTheme.font12Reguler.copyWith(color: colors.red1),
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon,
          prefixIconConstraints: const BoxConstraints.tightFor(),
        ),
        style: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return textTheme.font16Reguler.copyWith(color: colors.grey3);
          }
          return textTheme.font16Reguler;
        }),
        validator: (value) {
          String? errorMessage = widget.validator?.call(value ?? '');
          widget.onValidate?.call(errorMessage);
          return errorMessage;
        },
        onFieldSubmitted: widget.onSubmit,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((widget.labelText ?? '').isNotEmpty) ...[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.labelText,
                  style: textTheme.font16Medium,
                ),
                if (widget.showAsterisk)
                  TextSpan(
                    text: '*',
                    style: textTheme.font16Medium.copyWith(
                      color: colors.red1,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.0),
        ],
        if ((widget.subLabelText ?? '').isNotEmpty) ...[
          Text(
            widget.subLabelText ?? '',
            style: textTheme.font12Reguler.copyWith(color: colors.grey1),
          ),
        ],
        if (widget.labelText.isNotNullOrEmpty) SizedBox(height: 6.0),
        if (widget.onFieldTap != null)
          GestureDetector(
            onTap: widget.onFieldTap,
            child: AbsorbPointer(
              child: inputField,
            ),
          ),
        if (widget.onFieldTap == null) inputField,
      ],
    );
  }
}
