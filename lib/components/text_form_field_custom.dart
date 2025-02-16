import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wigdeg wrapper of TextFormField customized for general inputs
///
class TextFormFieldCustom extends StatelessWidget {
  final String? initialValue;
  final bool autofocus;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool? enabled;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final String? suffixText;
  final String? hintText;
  final String? labelText;
  final bool? disabledLabelColor;
  final String? errorText;
  final String? counterText;
  final bool autocorrect;
  final int? errorMaxLines;

  const TextFormFieldCustom(
      {super.key,
      this.initialValue,
      this.autofocus = false,
      this.autocorrect = true,
      this.focusNode,
      this.nextFocus,
      this.onFieldSubmitted,
      this.textInputAction = TextInputAction.next,
      this.keyboardType = TextInputType.text,
      this.controller,
      this.onChanged,
      this.textCapitalization = TextCapitalization.none,
      this.inputFormatters,
      this.maxLength,
      this.maxLines = 1,
      this.enabled,
      this.validator,
      this.suffixIcon,
      this.suffixText,
      this.hintText,
      this.labelText,
      this.disabledLabelColor,
      this.errorText,
      this.errorMaxLines,
      this.counterText = ""});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        initialValue: initialValue,
        autofocus: autofocus,
        autocorrect: autocorrect,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        controller: controller,
        onChanged: onChanged,
        maxLength: maxLength,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
        style: Theme.of(context).textTheme.titleSmall,
        decoration: InputDecoration(
          suffixText: suffixText,
          suffixStyle: Theme.of(context).textTheme.titleSmall,
          suffixIcon: suffixIcon,
          // focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.newPrimaryLight)),
          counterText: counterText,
          hintText: hintText,
          labelText: labelText,
          errorText: errorText,
          errorMaxLines: errorMaxLines ?? 2,
          errorStyle: const TextStyle(wordSpacing: 4.0),
          hintStyle: Theme.of(context).textTheme.labelLarge,
          contentPadding: const EdgeInsets.all(16.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
