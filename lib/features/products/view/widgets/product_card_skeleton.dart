import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_listing_demo/features/products/view/widgets/product_card.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  double _lineHeight(BuildContext context, TextStyle? style) {
    final fontSize = MediaQuery.textScalerOf(context).scale(style?.fontSize ?? 14);
    return fontSize * (style?.height ?? 1.2);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
          highlightColor: colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: _Bone(radius: 8)),
              SizedBox(height: 8.h),
              // Same line heights as the card's text, so the image area matches.
              SizedBox(
                height: _lineHeight(context, textTheme.titleSmall),
                child: Row(
                  children: [
                    const Expanded(child: _Bone(height: 14)),
                    SizedBox(width: 16.w),
                    const _Bone(width: 44, height: 14),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                height: _lineHeight(context, textTheme.bodySmall),
                child: const Align(alignment: Alignment.centerLeft, child: _Bone(width: 70, height: 10)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      gridDelegate: productGridDelegate(),
      itemCount: itemCount,
      itemBuilder: (_, _) => const ProductCardSkeleton(),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({this.width, this.height, this.radius = 4});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w ?? double.infinity,
      height: height?.h ?? double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius.r)),
    );
  }
}
