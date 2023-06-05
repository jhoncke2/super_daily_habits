import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
class ActivityInput extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final bool isOnError;
  final String errorMessage;
  final TextEditingController controller;
  final bool isAvaible;
  const ActivityInput({
    Key? key,
    required this.hintText,
    required this.onChanged,
    required this.isOnError,
    required this.errorMessage,
    required this.controller,
    this.isAvaible = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hintText,
          ),
          onChanged: onChanged,
          readOnly: !isAvaible,
        ),
        Visibility(
          visible: isOnError,
          child: Text(
            errorMessage,
            style: TextStyle(
              color: AppColors.errorText,
              fontSize: dimens.littleTextSize
            ),
          )  
        )
      ],
    );
  }
}