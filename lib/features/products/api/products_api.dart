import 'package:product_listing_demo/core/config/app_constants.dart';
import 'package:product_listing_demo/core/network/api_client.dart';
import 'package:product_listing_demo/core/network/api_response.dart';
import 'package:product_listing_demo/features/products/model/products_page.dart';

class ProductsApi {
  ProductsApi([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<(String?, ProductsPage?)> products({required int skip, required int limit}) {
    return _client
        .get(Apis.products, queryParameters: {'skip': skip, 'limit': limit}, parser: ProductsPage.fromJson)
        .result;
  }
}
