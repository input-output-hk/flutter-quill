import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    required this.height,
    required this.width,
    super.key,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
