import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.placeholderUrl, this.size, this.fit = BoxFit.cover});

  final String url;

  // An already cached smaller image to show until [url] has loaded.
  final String? placeholderUrl;
  final double? size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dimension = size?.r;

    final loading = Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: SizedBox(
        width: dimension,
        height: dimension,
        child: const ColoredBox(color: Colors.white),
      ),
    );

    final fallback = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: SizedBox(
        width: dimension,
        height: dimension,
        child: Icon(Icons.image_not_supported_outlined, color: colorScheme.onSurfaceVariant, size: 30.sp),
      ),
    );

    if (url.isEmpty) return fallback;

    return CachedNetworkImage(
      imageUrl: url,
      width: dimension,
      height: dimension,
      fit: fit,
      placeholder: (_, _) {
        final placeholder = placeholderUrl;
        if (placeholder == null || placeholder.isEmpty || placeholder == url) return loading;
        return CachedNetworkImage(
          imageUrl: placeholder,
          width: dimension,
          height: dimension,
          fit: fit,
          fadeInDuration: Duration.zero,
          placeholder: (_, _) => loading,
          errorWidget: (_, _, _) => loading,
        );
      },
      errorWidget: (_, _, _) => fallback,
    );
  }
}
