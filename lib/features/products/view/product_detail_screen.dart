import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_listing_demo/features/products/model/product.dart';
import 'package:product_listing_demo/features/products/view/widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;

  Product get _product => widget.product;

  List<String> get _images => _product.images.isNotEmpty ? _product.images : [_product.thumbnail];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.only(bottom: 32.h),
          children: [
            _buildGallery(colorScheme),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_product.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4.h),
                  Text(
                    [_product.categoryLabel, ?_product.brand].join(' · '),
                    style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 20.h),
                  _InfoCard(
                    rows: [
                      (Icons.local_shipping_outlined, _product.shippingInformation),
                      (Icons.verified_user_outlined, _product.warrantyInformation),
                      (Icons.assignment_return_outlined, _product.returnPolicy),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(ColorScheme colorScheme) {
    // Starts at the very top of the screen, under the status bar.
    return SizedBox(
      height: 440.h,
      child: ColoredBox(
        color: colorScheme.surface,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: _images.length,
              onPageChanged: (index) => setState(() => _imageIndex = index),
              itemBuilder: (_, index) {
                final image = ProductImage(url: _images[index], placeholderUrl: index == 0 ? _product.thumbnail : null);
                return index == 0 ? Hero(tag: 'product-${_product.id}', child: image) : image;
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RoundButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.maybePop(context)),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Pill(
                            children: [
                              Icon(Icons.star_rounded, size: 18.r, color: colorScheme.secondary),
                              SizedBox(width: 4.w),
                              Text(
                                _product.rating.toStringAsFixed(1),
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _StockPill(status: _product.availabilityStatus, stock: _product.stock),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              bottom: 16.h,
              child: _Pill(
                children: [
                  Text(
                    _product.formattedPrice,
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: colorScheme.primary),
                  ),
                  if (_product.hasDiscount) ...[
                    SizedBox(width: 8.w),
                    Text(
                      '-${_product.discountPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: colorScheme.secondary),
                    ),
                  ],
                ],
              ),
            ),
            if (_images.length > 1)
              Positioned(
                right: 20.w,
                bottom: 30.h,
                child: Row(
                  children: [
                    for (var i = 0; i < _images.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(left: 4.w),
                        width: (i == _imageIndex ? 18 : 6).w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: i == _imageIndex ? colorScheme.primary : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 40.r,
          child: Icon(icon, size: 18.r, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const StadiumBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill({required this.status, required this.stock});

  final String? status;
  final int stock;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Out of Stock' => Theme.of(context).colorScheme.error,
      'Low Stock' => const Color(0xFFE6A23C),
      _ => const Color(0xFF2E9E5B),
    };

    return _Pill(
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          '${status ?? 'In Stock'} · $stock',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<(IconData, String?)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = rows.where((row) => row.$2 != null && row.$2!.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Column(
          children: [
            for (final (icon, text) in visible)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  children: [
                    Icon(icon, size: 20.r, color: theme.colorScheme.primary),
                    SizedBox(width: 12.w),
                    Expanded(child: Text(text!, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
