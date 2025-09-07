import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB4A582), // RIKYUSHIRACHA
          image: DecorationImage(
            image: const AssetImage("assets/img/texture.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              const Color(0xFFB4A582).withOpacity(0.9),
              BlendMode.modulate,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      bottom: bottom,
    );
  }
}
