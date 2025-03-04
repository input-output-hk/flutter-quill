import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webviewimage/webviewimage.dart';

import 'web_cors_image_config.dart';

class WebImageView extends StatelessWidget {
  const WebImageView({
    required this.animation,
    required this.displayConfig,
    required this.htmlContent,
    required this.height,
    required this.width,
    required this.debugPrint,
    required this.onWebViewCreated,
    required this.onImageLoad,
    required this.onTap,
    required this.onError,
    this.onImageTap,
    super.key,
  });

  final Animation<double> animation;
  final WebImageConfig displayConfig;
  final String htmlContent;
  final double height;
  final double width;
  final bool debugPrint;
  final void Function(WebViewXController) onWebViewCreated;
  final DartCallback Function() onImageLoad;
  final DartCallback Function() onTap;
  final DartCallback Function() onError;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    // Check if a menu is likely open
    final isMenuOpen = MediaQuery.of(context).viewInsets.bottom > 0 ||
        Navigator.of(context).canPop();

    return FadeTransition(
      opacity: animation,
      child: Align(
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: displayConfig.borderRadius,
          child: Container(
            color: displayConfig.backgroundColor,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    // Ignore all pointer events when a menu is open
                    ignoring: isMenuOpen,
                    child: WebViewX(
                      key: const ValueKey('web_cors_image'),
                      ignoreAllGestures: true,
                      initialContent: htmlContent,
                      initialSourceType: SourceType.html,
                      height: height,
                      width: width,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: onWebViewCreated,
                      onPageFinished: (src) {
                        if (debugPrint) {
                          if (kDebugMode) {
                            print(
                                '✓ WebCorsImage: Page has finished loading\n');
                          }
                        }
                      },
                      jsContent: const {
                        EmbeddedJsContent(
                          webJs: 'function onClick() { callbackTap(true) }',
                          mobileJs:
                              'function onClick() { callbackTap.postMessage(true) }',
                        ),
                        EmbeddedJsContent(
                          webJs: 'function onLoad(msg) { callbackLoad(msg) }',
                          mobileJs:
                              'function onLoad(msg) { callbackLoad.postMessage(msg) }',
                        ),
                        EmbeddedJsContent(
                          webJs: 'function onTap(msg) { callbackTap(msg) }',
                          mobileJs:
                              'function onTap(msg) { callbackTap.postMessage(msg) }',
                        ),
                        EmbeddedJsContent(
                          webJs: 'function onError(msg) { callbackError(msg) }',
                          mobileJs:
                              'function onError(msg) { callbackError.postMessage(msg) }',
                        ),
                      },
                      dartCallBacks: {
                        onImageLoad(),
                        onTap(),
                        onError(),
                      },
                      webSpecificParams: const WebSpecificParams(
                        webAllowFullscreenContent: false,
                      ),
                      mobileSpecificParams: const MobileSpecificParams(
                        androidEnableHybridComposition: true,
                      ),
                    ),
                  ),
                ),
                if (isMenuOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
