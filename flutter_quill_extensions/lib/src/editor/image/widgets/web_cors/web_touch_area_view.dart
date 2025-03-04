import 'package:flutter/material.dart';

class TouchAreaView extends StatelessWidget {
  const TouchAreaView({
    required this.imagePath,
    required this.height,
    required this.width,
    required this.onPointer,
    super.key,
    this.onTap,
  });

  final String imagePath;
  final double height;
  final double width;
  final bool onPointer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Semantics(
        label: 'Image: ${imagePath.split('/').last}',
        image: true,
        button: onTap != null,
        child: MouseRegion(
          cursor:
              onPointer ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.deferToChild,
            child: Container(
              height: height,
              width: width,
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
