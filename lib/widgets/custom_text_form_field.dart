import 'package:flutter/material.dart';
import 'package:project_ease/utils/app_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isPassword;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: isTablet ? AppFonts.bodyLarge : AppFonts.bodyMedium,
        ),
        labelStyle: TextStyle(
          fontSize: isTablet ? AppFonts.bodyLarge : AppFonts.bodyMedium,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: isTablet ? 28 : 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      style: TextStyle(
        fontSize: isTablet ? AppFonts.bodyLarge : AppFonts.bodyMedium,
      ),
      validator: widget.validator,
    );
  }
}