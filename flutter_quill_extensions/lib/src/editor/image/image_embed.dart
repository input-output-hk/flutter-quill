import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/element_utils/element_utils.dart';
import 'config/image_config.dart';
import 'image_embed_types.dart'
    show ImageEmbedBuilderErrorWidgetBuilder, ImageEmbedBuilderProviderBuilder;
import 'widgets/image.dart';
import 'widgets/web_cors/web_cors_image.dart';

class QuillEditorImageEmbedBuilder extends EmbedBuilder {
  QuillEditorImageEmbedBuilder({
    required this.config,
  });
  final QuillEditorImageEmbedConfig config;

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final imageSource = standardizeImageUrl(embedContext.node.value.data);
    final ((imageSize), margin, alignment) = getElementAttributes(
      embedContext.node,
      context,
    );

    final width = imageSize.width;
    final height = imageSize.height;
    final imageData = _createImageData(
      context: context,
      imageSource: imageSource,
      width: width,
      height: height,
      alignment: alignment,
      imageProviderBuilder: config.imageProviderBuilder,
      imageErrorWidgetBuilder: config.imageErrorWidgetBuilder,
      errorWidget: config.errorWidget,
    );

    // void showImageMenu() {
    //   final onImageClicked = config.onImageClicked;
    //   if (onImageClicked != null) {
    //     onImageClicked(imageSource);
    //     return;
    //   }
    //   showDialog(
    //     context: context,
    //     builder: (_) => ImageOptionsMenu(
    //       controller: embedContext.controller,
    //       config: config,
    //       imageSource: imageSource,
    //       imageSize: imageSize,
    //       readOnly: embedContext.readOnly,
    //       imageProvider: imageData.provider ?? createPlaceholderImage(),
    //     ),
    //   );
    // }

    // Wrap the image in a stack with transparent overlay for better tap detection
    // final imageWithOverlay = Stack(
    //   children: [
    //     imageData.widget,
    //     Positioned.fill(
    //       child: GestureDetector(
    //         onTap: showImageMenu,
    //         child: Container(
    //           color: Colors.transparent,
    //         ),
    //       ),
    //     ),
    //   ],
    // );

    // if (margin != null) {
    //   return Padding(
    //     padding: EdgeInsets.all(margin),
    //     child: imageWithOverlay,
    //   );
    // }

    return imageData.widget;
  }
}

({
  Widget widget,
  ImageProvider<Object>? provider,
}) _createImageData({
  required BuildContext context,
  required String imageSource,
  AlignmentGeometry alignment = Alignment.center,
  double? width,
  double? height,
  ImageEmbedBuilderProviderBuilder? imageProviderBuilder,
  ImageEmbedBuilderErrorWidgetBuilder? imageErrorWidgetBuilder,
  Widget? errorWidget,
}) {
  final screenSize = MediaQuery.sizeOf(context);
  final defaultWidth = screenSize.width * 0.8;

  // If width is provided but height is not, maintain aspect ratio
  // If neither is provided, use responsive defaults
  final effectiveWidth = width ?? defaultWidth;
  final effectiveHeight =
      height ?? (width != null ? width * 0.75 : defaultWidth * 0.6);

  if (kIsWeb) {
    // Create a unique key based on image source and dimensions
    // This ensures each image has a stable identity in the document
    final key =
        ValueKey('web_image_${imageSource}_${effectiveWidth}_$effectiveHeight');

    // Create an ImageProvider for the menu operations
    final imageProvider = getImageProviderByImageSource(
      imageSource,
      context: context,
      imageProviderBuilder: imageProviderBuilder,
    );

    final webImage = WebCorsImage(
      key: key,
      imagePath: imageSource,
      width: effectiveWidth,
      height: effectiveHeight,
      imageCache: imageProvider,
      error: errorWidget,
    );

    return (
      widget: RepaintBoundary(
        child: SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
          child: webImage,
        ),
      ),
      provider: imageProvider
    );
  } else {
    final imageWidget = getImageWidgetByImageSource(
      context: context,
      imageSource,
      imageProviderBuilder: imageProviderBuilder,
      imageErrorWidgetBuilder: imageErrorWidgetBuilder,
      alignment: alignment,
      height: effectiveHeight,
      width: effectiveWidth,
    );

    // Use the same key-based approach for consistency
    final key =
        ValueKey('image_${imageSource}_${effectiveWidth}_$effectiveHeight');

    return (
      widget: RepaintBoundary(
        key: key,
        child: imageWidget,
      ),
      provider: imageWidget.image
    );
  }
}
