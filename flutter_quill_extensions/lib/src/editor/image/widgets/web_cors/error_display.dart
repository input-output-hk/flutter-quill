import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    required this.height,
    required this.width,
    required this.errorMessage,
    super.key,
  });

  final double height;
  final double width;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: height,
        width: width,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    errorMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
