import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class ErrorPanel extends StatelessWidget {
  final String errorTitle;
  final String? errorContent;
  const ErrorPanel({
    required this.errorTitle,
    this.errorContent,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.25),
        border: Border.all(
          color: AppColors.error,
          width: 1
        ),
        borderRadius: BorderRadius.circular(
          5
        )
      ),
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: dimens.normalContainerVerticalMargin,
        left: dimens.getWidthPercentage(0.01),
        right: dimens.getWidthPercentage(0.01)
      ),
      padding: EdgeInsets.symmetric(
        vertical: dimens.scaffoldVerticalPadding,
        horizontal: dimens.getWidthPercentage(0.015)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            errorTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: dimens.normalTextSize
            )
          ),
          Visibility(
            visible: errorContent != null,
            child: Text(
              errorContent??'',
              style: TextStyle(
                fontSize: dimens.littleTextSize
              )
            )
          )
        ]
      )
    );
  }
}