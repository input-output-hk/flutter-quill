import 'package:flutter/material.dart';

/// Configuration for feedback widgets
class WebImageFeedbackConfig {
  const WebImageFeedbackConfig({
    this.onLoading = const CircularProgressIndicator(),
    this.onError = const Icon(Icons.error),
    this.retryAttempts = 0,
    this.retryDelay = const Duration(seconds: 2),
  });

  final Widget onLoading;
  final Widget onError;
  final int retryAttempts;
  final Duration retryDelay;
}
