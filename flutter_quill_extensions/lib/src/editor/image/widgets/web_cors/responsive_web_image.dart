import 'package:flutter/material.dart';

import 'web_cors_image.dart';

class ResponsiveWebImage extends StatefulWidget {
  const ResponsiveWebImage({
    required this.imagePath,
    this.width,
    this.height,
    super.key,
  });

  final String imagePath;
  final double? width;
  final double? height;

  @override
  State<ResponsiveWebImage> createState() => _ResponsiveWebImageState();
}

class _ResponsiveWebImageState extends State<ResponsiveWebImage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  double? screenWidth;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (mounted) {
      _controller.reset();
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
      });
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (screenWidth == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: FractionallySizedBox(
            widthFactor: 0.8 * _animation.value,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final computedWidth = widget.width ?? constraints.maxWidth;
                final computedHeight =
                    widget.height ?? (computedWidth * 9 / 16);
                final aspectRatio = computedWidth > 0 && computedHeight > 0
                    ? computedWidth / computedHeight
                    : 1.0;

                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: WebCorsImage(
                      key: ValueKey(
                          '${screenWidth}_${computedWidth}_$computedHeight'),
                      imagePath: widget.imagePath,
                      width: computedWidth,
                      height: computedHeight,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
