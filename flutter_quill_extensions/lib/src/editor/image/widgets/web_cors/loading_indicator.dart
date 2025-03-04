import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    required this.height,
    required this.width,
    required this.loadingWidget,
    this.retryCount = 0,
    this.maxRetryAttempts = 0,
    super.key,
  });

  final double height;
  final double width;
  final Widget loadingWidget;
  final int retryCount;
  final int maxRetryAttempts;

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
              loadingWidget,
              if (retryCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Retrying... ($retryCount/$maxRetryAttempts)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
