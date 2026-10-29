import 'package:product_listing_demo/core/network/api_response.dart';
import 'package:product_listing_demo/features/products/model/product.dart';

class ProductsPage {
  const ProductsPage({required this.products, required this.total, required this.skip, required this.limit});

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductsPage.fromJson(dynamic json) {
    final data = asJsonMap(json);
    return ProductsPage(
      products: asJsonList(data['products']).map(Product.fromJson).toList(),
      total: (data['total'] as num?)?.toInt() ?? 0,
      skip: (data['skip'] as num?)?.toInt() ?? 0,
      limit: (data['limit'] as num?)?.toInt() ?? 0,
    );
  }
}
