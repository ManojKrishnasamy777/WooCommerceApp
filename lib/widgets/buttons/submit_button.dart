import 'package:e_com/core/core.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.height = 50,
    this.width,
    this.padding,
    this.isLoading = false,
  });

  final Function()? onPressed;
  final Widget child;
  final Widget? icon;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  Widget _button(BuildContext context) => icon != null
      ? FilledButton.icon(
          onPressed: onPressed,
          label: child,
          icon: isLoading ? _loading(context) : icon!,
        )
      : FilledButton(
          onPressed: onPressed, child: isLoading ? _loading(context) : child);

  Widget _loading(BuildContext context) => SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: context.colorTheme.onPrimary,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: AnimatedContainer(
        duration: Times.medium,
        height: height,
        width: width,
        child: _button(context),
      ),
    );
  }
}
