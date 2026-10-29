import 'package:product_listing_demo/core/network/api_response.dart';

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
    this.brand,
    this.availabilityStatus,
    this.warrantyInformation,
    this.shippingInformation,
    this.returnPolicy,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;
  final String? brand;
  final String? availabilityStatus;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? returnPolicy;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  bool get hasDiscount => discountPercentage > 0;

  String get categoryLabel => category
      .split('-')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  factory Product.fromJson(dynamic json) {
    final data = asJsonMap(json);
    final images = data['images'];
    return Product(
      id: (data['id'] as num?)?.toInt() ?? 0,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (data['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      thumbnail: data['thumbnail'] as String? ?? '',
      images: images is List ? images.whereType<String>().toList() : const [],
      brand: data['brand'] as String?,
      availabilityStatus: data['availabilityStatus'] as String?,
      warrantyInformation: data['warrantyInformation'] as String?,
      shippingInformation: data['shippingInformation'] as String?,
      returnPolicy: data['returnPolicy'] as String?,
    );
  }
}
