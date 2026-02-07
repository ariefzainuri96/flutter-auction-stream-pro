import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/enums/page_state.dart';
import '../constants/text_theme.dart';
import '../utils/widget_extension.dart';
import 'custom_error.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String? label;
  final String hintText;
  final List<T> items;
  final T? selectedValue;
  final Function(T?)? onChanged;
  final Widget Function(T item)? contentBuilder;
  final bool showAsterisk;
  final PageState state;
  final Function()? onRetry;
  final bool enable;
  final bool isExpanded;

  const CustomDropdown({
    super.key,
    this.label,
    this.showAsterisk = false,
    required this.hintText,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.contentBuilder,
    this.state = PageState.initial,
    this.onRetry,
    this.enable = true,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: isExpanded ? double.infinity : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (label ?? '').isNotEmpty
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: label,
                          style: textTheme.font16Medium,
                        ),
                        if (showAsterisk)
                          TextSpan(
                            text: '*',
                            style: textTheme.font16Medium.copyWith(
                              color: colors.red1,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 8),
            if (state == PageState.loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(),
              )
            else if (state == PageState.error)
              CustomError(onRetry: onRetry)
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.grey5, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    isExpanded: true,
                    isDense: true,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.chevron_right),
                    value: selectedValue,
                    hint: Text(
                      hintText,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    items: items
                        .map(
                          (value) => DropdownMenuItem<T>(
                            value: value,
                            child: contentBuilder != null
                                ? contentBuilder!(value)
                                : Text(
                                    value.toString(),
                                    style: textTheme.font16Reguler,
                                  ),
                          ),
                        )
                        .toList(),
                    onChanged: enable ? onChanged : null,
                  ).padSymmetric(horizontal: 16, vertical: 10),
                ),
              ),
          ],
        ),
      );
}
