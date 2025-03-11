import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/element_utils/element_utils.dart';
import 'config/image_config.dart';
import 'image_embed_types.dart'
    show ImageEmbedBuilderErrorWidgetBuilder, ImageEmbedBuilderProviderBuilder;
import 'image_menu.dart';
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

    // Create image widget and get its provider in one place to avoid duplication
    final imageData = _createImageData(
      context: context,
      imageSource: imageSource,
      width: width,
      height: height,
      alignment: alignment,
      imageProviderBuilder: config.imageProviderBuilder,
      imageErrorWidgetBuilder: config.imageErrorWidgetBuilder,
    );

    final imageWidget = imageData.widget;

    // final imageWidget = kIsWeb
    //     ? ResponsiveWebImage(
    //         imagePath: imageSource,
    //         width: width,
    //         height: height,
    //       )
    //     : getImageWidgetByImageSource(
    //         context: context,
    //         imageSource,
    //         imageProviderBuilder: config.imageProviderBuilder,
    //         imageErrorWidgetBuilder: config.imageErrorWidgetBuilder,
    //         alignment: alignment,
    //         height: height,
    //         width: width,
    //       );

    return GestureDetector(
      onTap: () {
        final onImageClicked = config.onImageClicked;
        if (onImageClicked != null) {
          onImageClicked(imageSource);
          return;
        }
        showDialog(
          context: context,
          builder: (_) => ImageOptionsMenu(
            controller: embedContext.controller,
            config: config,
            imageSource: imageSource,
            imageSize: imageSize,
            readOnly: embedContext.readOnly,
            imageProvider: imageData.provider ?? _createPlaceholderImage(),
          ),
        );
      },
      child: Builder(
        builder: (context) {
          if (margin != null) {
            return Padding(
              padding: EdgeInsets.all(margin),
              child: imageWidget,
            );
          }
          return imageWidget;
        },
      ),
    );
  }
}

/// Helper method to create image data and avoid code duplication
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
}) {
  // Use a better default size - either the provided size or a reasonable default
  // that's larger than 100px and based on screen size
  final screenSize = MediaQuery.sizeOf(context);
  final defaultWidth = screenSize.width * 0.9; // 70% of screen width

  // Use provided dimensions or defaults
  final effectiveWidth = width ?? defaultWidth;
  final effectiveHeight = height ??
      effectiveWidth *
          0.6; // Maintain reasonable aspect ratio if height not specified

  if (kIsWeb) {
    final webImage = WebCorsImage(
      imagePath: imageSource,
      width: effectiveWidth,
      height: effectiveHeight,
    );
    return (
      widget: SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: webImage,
      ),
      provider: webImage.imageCache
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
    return (widget: imageWidget, provider: imageWidget.image);
  }
}

/// Creates a simple placeholder image from memory instead of requiring an asset
ImageProvider _createPlaceholderImage() {
  // Create a 1x1 pixel transparent image
  final transparentPixel = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82
  ]);
  return MemoryImage(transparentPixel);
}
