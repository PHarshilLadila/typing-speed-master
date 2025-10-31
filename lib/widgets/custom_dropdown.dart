// custom_dropdown.dart
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isExpanded;
  final Color? dropdownColor;
  final TextStyle? style;
  final Widget? icon;
  final BorderRadius? borderRadius;
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
    this.dropdownColor,
    this.style,
    this.icon,
    this.borderRadius,
    required this.isDarkMode,
    this.lightModeColor = Colors.grey,
    this.darkModeColor = Colors.grey,
    this.contentPadding,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? darkModeColor : lightModeColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: isDarkMode ? Border.all(color: Colors.grey.shade700) : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<T>(
            isDense: true,
            value: value,
            onChanged: enabled ? onChanged : null,
            items: items,
            isExpanded: isExpanded,
            dropdownColor:
                dropdownColor ?? (isDarkMode ? Colors.grey[900] : Colors.white),
            style:
                style ??
                TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  contentPadding ?? const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon:
                icon ??
                Icon(
                  Icons.arrow_drop_down,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
          ),
        ),
      ),
    );
  }
}
