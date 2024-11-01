import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

class ErrorContainer extends StatelessWidget {
  final String? errorMessageCode;
  final String? errorMessageText;
  final String? buttonText;
  final bool? showRetryButton;
  final bool? showErrorImage;
  final Color? errorMessageColor;
  final double? errorMessageFontSize;
  final Function? onTapRetry;
  final Color? retryButtonBackgroundColor;
  final Color? retryButtonTextColor;

  const ErrorContainer({
    super.key,
    this.errorMessageCode,
    this.errorMessageText,
    this.errorMessageColor,
    this.errorMessageFontSize,
    this.onTapRetry,
    this.showErrorImage,
    this.retryButtonBackgroundColor,
    this.retryButtonTextColor,
    this.showRetryButton, this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        ScaleEffect(
          duration: Duration(
            milliseconds: 200,
          ),
          curve: Curves.bounceOut,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.35),
            child: SvgPicture.asset(
              errorMessageText.toString().contains('No Internet')
                  ? 'assets/noInternet.svg'
                  : 'assets/somethingWentWrong.svg',
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              errorMessageText ?? 'Something went wrong, Please try again!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: errorMessageColor ??
                    Theme.of(context).colorScheme.secondary,
                fontSize: errorMessageFontSize ?? 16,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          (showRetryButton ?? true)
              ? Container(
                  height: 40,
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      onTapRetry?.call();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          retryButtonBackgroundColor ??
                              Theme.of(context).colorScheme.primary),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    child: Text(
                      buttonText ?? 'Retry',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
