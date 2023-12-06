import 'package:flutter/material.dart';

// customized text field with some constant visual aspects

class CustomTextField extends StatelessWidget {
  final String? initialValue;
  final Text label;
  final String hintText;
  final int? maxLenght;
  final TextInputType? keyboardType;
  final Function(String?) onSaved;
  final String? Function(String?) validator;
  const CustomTextField({
    this.initialValue,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.maxLenght,
    required this.onSaved,
    required this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        errorStyle: const TextStyle(height: 0.2),
        label: label,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      maxLength: maxLenght,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
