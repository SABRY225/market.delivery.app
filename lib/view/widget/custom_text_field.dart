import 'package:flutter/material.dart';

class CustomCheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int? maxLength;
  final IconData? icon;
  final String? prefixText;
  final String? Function(String?)? validator;

  const CustomCheckoutField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLength,
    this.icon,
    this.prefixText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: prefixText != null 
          ? Padding(padding: const EdgeInsets.all(15), child: Text(prefixText!, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)))
          : Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      maxLength: maxLength,
      validator: validator,
    );
  }
}