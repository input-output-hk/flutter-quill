import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    required this.height,
    required this.width,
    required this.errorWidget,
    required this.errorMessage,
    required this.retryCount,
    required this.maxRetryAttempts,
    required this.onRetry,
    super.key,
  });

  final double height;
  final double width;
  final Widget errorWidget;
  final String errorMessage;
  final int retryCount;
  final int maxRetryAttempts;
  final VoidCallback onRetry;

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
              errorWidget,
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    errorMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (retryCount < maxRetryAttempts)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRetry,
                  tooltip: 'Retry loading',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
