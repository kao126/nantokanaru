import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;

  const CustomContainer({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF2),
        image: DecorationImage(
          image: const AssetImage("assets/img/texture.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFFFCFAF2).withOpacity(0.9),
            BlendMode.modulate,
          ),
        ),
      ),
      child: child,
    );
  }
}
