import 'package:flutter/material.dart';
import 'package:webviewimage/webviewimage.dart';

import 'box_fit_web.dart';
import 'error_display.dart';
import 'loading_indicator.dart';
import 'web_cors_image_config.dart';
import 'web_image_animation_config.dart';
import 'web_image_feedback_config.dart';
import 'web_image_view.dart';

class WebCorsImage extends StatefulWidget {
  const WebCorsImage({
    required this.imagePath,
    required this.height,
    required this.width,
    super.key,
    this.imageCache,
    this.debugPrint = false,
    this.onTap,
    this.onImageLoaded,
    this.onImageError,
    this.displayConfig = const WebImageConfig(),
    this.animationConfig = const WebImageAnimationConfig(),
    this.feedbackConfig = const WebImageFeedbackConfig(),
  });

  /// The URL or path of the image to display
  final String imagePath;

  /// Local image to use as a cache or fallback
  final ImageProvider? imageCache;

  /// Height of the image container
  final double height;

  /// Width of the image container
  final double width;

  /// Visual configuration for the image display
  final WebImageConfig displayConfig;

  /// Animation configuration for transitions
  final WebImageAnimationConfig animationConfig;

  /// Feedback widget configuration (loading, error states)
  final WebImageFeedbackConfig feedbackConfig;

  /// Print debug information
  final bool debugPrint;

  /// Callback function when the image is tapped
  final VoidCallback? onTap;

  /// Callback function when the image successfully loads
  final VoidCallback? onImageLoaded;

  /// Callback function when the image fails to load
  final Function(String error)? onImageError;

  @override
  State<WebCorsImage> createState() => _WebCorsImageState();
}

class _WebCorsImageState extends State<WebCorsImage>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late WebViewXController _webviewController;

  bool _loading = true;
  bool _error = false;
  String _errorMessage = '';
  int _retryCount = 0;

  late final String _htmlContent;

  @override
  void initState() {
    super.initState();

    _initHtmlPage();

    _configureAnimation();
  }

  void _initHtmlPage() {
    _htmlContent = _buildHtmlImagePage(
      image: widget.imagePath,
      pointer: widget.displayConfig.onPointer,
      fitWeb: widget.displayConfig.fitWeb,
      height: widget.height,
      width: widget.width,
    );
  }

  void _configureAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.animationConfig.duration,
      ),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationConfig.curve,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Attempts to retry loading the image
  void _retryLoading() {
    if (_retryCount < widget.feedbackConfig.retryAttempts) {
      setState(() {
        _loading = true;
        _error = false;
        _retryCount++;
      });

      // Reload WebView with the same content
      Future.delayed(widget.feedbackConfig.retryDelay, () {
        if (mounted) {
          try {
            _webviewController.loadContent(
              _htmlContent,
              SourceType.html,
            );
          } catch (e) {
            debugPrint('WebCorsImage: Error reloading content: $e');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!_error)
            WebImageView(
              animation: _animation,
              displayConfig: widget.displayConfig,
              htmlContent: _htmlContent,
              height: widget.height,
              width: widget.width,
              debugPrint: widget.debugPrint,
              onWebViewCreated: (controller) => _webviewController = controller,
              onImageLoad: _onImageLoad,
              onTap: _onTap,
              onError: _onError,
              onImageTap: widget.onTap,
            ),
          if (!_error && _loading)
            LoadingIndicator(
              height: widget.height,
              width: widget.width,
              loadingWidget: widget.feedbackConfig.onLoading,
              retryCount: _retryCount,
              maxRetryAttempts: widget.feedbackConfig.retryAttempts,
            ),
          if (_error)
            ErrorDisplay(
              height: widget.height,
              width: widget.width,
              errorWidget: widget.feedbackConfig.onError,
              errorMessage: _errorMessage,
              retryCount: _retryCount,
              maxRetryAttempts: widget.feedbackConfig.retryAttempts,
              onRetry: _retryLoading,
            ),
        ],
      ),
    );
  }

  DartCallback _onImageLoad() {
    return DartCallback(
      name: 'callbackLoad',
      callBack: (msg) {
        if (msg) {
          setState(() => _loading = false);
          widget.onImageLoaded?.call();
        }
      },
    );
  }

  DartCallback _onTap() {
    return DartCallback(
      name: 'callbackTap',
      callBack: (msg) {
        if (msg) {
          widget.onTap?.call();
        }
      },
    );
  }

  DartCallback _onError() {
    return DartCallback(
      name: 'callbackError',
      callBack: (msg) {
        var errorMsg = 'Image failed to load';

        try {
          if (msg is List && msg.isNotEmpty) {
            errorMsg =
                msg.length > 1 && msg[1] != null ? msg[1].toString() : errorMsg;
          } else if (msg is Map) {
            errorMsg = 'Image load error: ${msg.toString()}';
          } else if (msg is String) {
            errorMsg = msg;
          }
        } catch (e) {
          // If any error occurs during type checking or conversion, use default message
          errorMsg = 'Image failed to load: ${e.toString()}';
        }

        setState(() {
          _error = true;
          _errorMessage = errorMsg;
        });

        widget.onImageError?.call(errorMsg);

        if (widget.feedbackConfig.retryAttempts > 0) {
          _retryLoading();
        }
      },
    );
  }

  String _buildHtmlImagePage({
    required String image,
    required bool pointer,
    required double height,
    required double width,
    required BoxFitWeb fitWeb,
  }) {
    return """<!DOCTYPE html>
            <html>
              <head>
                <style type="text/css" rel="stylesheet">
                  html, body {
                    margin: 0;
                    padding: 0;
                    height: 100%;
                    width: 100%;
                    overflow: hidden;
                    background-color: transparent;
                    pointer-events: none;
                    z-index: -1;
                  }
                  #imageContainer {
                    width: 100%;
                    height: 100%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    pointer-events: none;
                    z-index: 0;
                  }
                  #myImg {
                    cursor: ${pointer ? "pointer" : "default"};
                    transition: 0.3s;
                    width: ${"$width" "px"};
                    height: ${"$height" "px"};
                    object-fit: ${fitWeb.name(fitWeb as Fit)};
                    pointer-events: ${pointer ? "auto" : "none"};
                    z-index: 1;
                  }
                  #myImg:hover {opacity: ${pointer ? "0.7" : "1"}};}
                  
                  /* Disable all pointer events when a menu is detected */
                  .menu-open {
                    pointer-events: none !important;
                    opacity: 1 !important;
                  }
                </style>
                <meta charset="utf-8">
                <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
                <meta http-equiv="Content-Security-Policy" 
                content="default-src * gap:; script-src * 'unsafe-inline' 'unsafe-eval'; connect-src *; 
                img-src * data: blob: android-webview-video-poster:; style-src * 'unsafe-inline';">
              </head>
              <body>
                <div id="imageContainer">
                  <img id="myImg"
                       src="$image"
                       alt="Image"
                       frameborder="0"
                       allow="fullscreen"
                       allowfullscreen
                       onclick="onClick()"
                       onerror="onError(this)">
                </div>
                <script>
                  // Global variable to track if a menu is open
                  var isMenuOpen = false;
                  
                  // Handle load event
                  window.onload = function(){
                    try {
                      callbackLoad(true);
                      
                      // Set up a mutation observer to detect when a menu might be open
                      setupMenuDetection();
                    } catch(e) {
                      console.error('Load callback error:', e);
                    }
                  }
                  
                  // Set up detection for when a menu might be open
                  function setupMenuDetection() {
                    // Listen for blur events which might indicate a menu is open
                    window.addEventListener('blur', function() {
                      disableInteraction(true);
                    });
                    
                    // Listen for focus events which might indicate a menu is closed
                    window.addEventListener('focus', function() {
                      disableInteraction(false);
                    });
                    
                    // Listen for mousedown events outside the image
                    document.addEventListener('mousedown', function(e) {
                      if (e.target.id !== 'myImg') {
                        disableInteraction(true);
                        // Set a timeout to re-enable interaction after the menu is likely closed
                        setTimeout(function() {
                          disableInteraction(false);
                        }, 500);
                      }
                    });
                    
                    // Listen for touchstart events outside the image
                    document.addEventListener('touchstart', function(e) {
                      if (e.target.id !== 'myImg') {
                        disableInteraction(true);
                        // Set a timeout to re-enable interaction after the menu is likely closed
                        setTimeout(function() {
                          disableInteraction(false);
                        }, 500);
                      }
                    });
                  }
                  
                  // Disable or enable interaction with the image
                  function disableInteraction(disable) {
                    isMenuOpen = disable;
                    var img = document.getElementById('myImg');
                    if (disable) {
                      img.classList.add('menu-open');
                      img.style.pointerEvents = 'none';
                    } else {
                      img.classList.remove('menu-open');
                      img.style.pointerEvents = '${pointer ? "auto" : "none"}';
                    }
                  }

                  // Handle click event
                  function onClick() {
                    try {
                      // Only trigger tap if no menu is open
                      if (!isMenuOpen) {
                        callbackTap(true);
                      }
                    } catch(e) {
                      console.error('Tap callback error:', e);
                    }
                  }

                  // Handle error event
                  function onError(source) {
                    let errorMsg = 'Image failed to load';
                    try {
                      // Log error details
                      if (source && source.src) {
                        errorMsg = 'Failed to load: ' + source.src;
                        console.error(errorMsg);
                      }

                      // Clear the src to prevent further errors
                      source.src = "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=";
                      source.onerror = "";

                      // Notify Dart - ensure we only pass a single argument to avoid issues in release mode
                      callbackError(errorMsg);
                    } catch(e) {
                      console.error('Error callback failed:', e);
                      // Fallback with a simple error message
                      callbackError('Image load error');
                    }
                    return true;
                  }
                </script>
              </body>
            </html>
    """;
  }
}
