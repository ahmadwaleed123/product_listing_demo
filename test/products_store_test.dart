import 'package:flutter_test/flutter_test.dart';
import 'package:product_listing_demo/features/products/api/products_api.dart';
import 'package:product_listing_demo/features/products/model/product.dart';
import 'package:product_listing_demo/features/products/model/products_page.dart';
import 'package:product_listing_demo/features/products/repository/products_repository.dart';
import 'package:product_listing_demo/features/products/store/products_store.dart';

class _FakeRepository extends ProductsRepository {
  _FakeRepository({this.total = 45}) : super(productsApi: ProductsApi());

  final int total;
  String? failWith;
  final requestedSkips = <int>[];

  @override
  Future<(String?, ProductsPage?)> fetchPage({required int skip, int limit = 20}) async {
    requestedSkips.add(skip);
    if (failWith != null) return (failWith, null);

    final count = (total - skip).clamp(0, limit);
    final products = List.generate(count, (i) => _product(skip + i + 1));
    return (null, ProductsPage(products: products, total: total, skip: skip, limit: limit));
  }

  Product _product(int id) => Product(
    id: id,
    title: 'Product $id',
    description: '',
    category: 'test',
    price: 10,
    discountPercentage: 0,
    rating: 4,
    stock: 1,
    thumbnail: '',
    images: const [],
  );
}

void main() {
  test('loads the first page', () async {
    final store = ProductsStore(_FakeRepository());
    await store.load();

    expect(store.products.length, 20);
    expect(store.total, 45);
    expect(store.hasMore, isTrue);
    expect(store.errorMessage, isNull);
  });

  test('loads more pages until everything is fetched', () async {
    final repository = _FakeRepository();
    final store = ProductsStore(repository);
    await store.load();
    await store.loadMore();
    await store.loadMore();
    await store.loadMore();

    expect(store.products.length, 45);
    expect(store.hasMore, isFalse);
    expect(repository.requestedSkips, [0, 20, 40]);
  });

  test('shows an error when the first page fails', () async {
    final store = ProductsStore(_FakeRepository()..failWith = 'No internet connection.');
    await store.load();

    expect(store.products, isEmpty);
    expect(store.errorMessage, 'No internet connection.');
    expect(store.isEmpty, isFalse);
  });

  test('keeps the list and exposes the error when a next page fails', () async {
    final repository = _FakeRepository();
    final store = ProductsStore(repository);
    await store.load();

    repository.failWith = 'Connection timeout.';
    await store.loadMore();

    expect(store.products.length, 20);
    expect(store.loadMoreError, 'Connection timeout.');
  });

  test('reports empty when the api returns no products', () async {
    final store = ProductsStore(_FakeRepository(total: 0));
    await store.load();

    expect(store.isEmpty, isTrue);
  });

  test('refresh replaces the list with the first page', () async {
    final store = ProductsStore(_FakeRepository());
    await store.load();
    await store.loadMore();
    await store.refresh();

    expect(store.products.length, 20);
    expect(store.products.first.id, 1);
  });
}
