import 'package:product_listing_demo/core/config/app_constants.dart';
import 'package:product_listing_demo/features/products/api/products_api.dart';
import 'package:product_listing_demo/features/products/model/products_page.dart';

class ProductsRepository {
  ProductsRepository({required ProductsApi productsApi}) : _productsApi = productsApi;

  final ProductsApi _productsApi;

  Future<(String?, ProductsPage?)> fetchPage({required int skip, int limit = AppConstants.pageSize}) {
    return _productsApi.products(skip: skip, limit: limit);
  }
}
