import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:product_listing_demo/core/navigation/app_messenger.dart';
import 'package:product_listing_demo/features/products/model/product.dart';
import 'package:product_listing_demo/features/products/repository/products_repository.dart';

class ProductsStore extends ChangeNotifier {
  ProductsStore(this._repository);

  final ProductsRepository _repository;

  final List<Product> _products = [];
  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);

  int _total = 0;
  int get total => _total;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _loadMoreError;
  String? get loadMoreError => _loadMoreError;

  // Bumped on every first-page request so a stale page never lands on a refreshed list.
  int _generation = 0;
  bool _disposed = false;

  bool get hasMore => _products.length < _total;

  bool get isEmpty => !_isLoading && _errorMessage == null && _products.isEmpty;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _notify();

    await _loadFirstPage();

    _isLoading = false;
    _notify();
  }

  Future<void> refresh() => _loadFirstPage();

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore || _errorMessage != null) return;

    final generation = _generation;
    _isLoadingMore = true;
    _loadMoreError = null;
    _notify();

    final (message, page) = await _repository.fetchPage(skip: _products.length);
    if (generation != _generation) return;

    _isLoadingMore = false;
    if (page == null) {
      _loadMoreError = message;
    } else {
      _total = page.total;
      _products.addAll(page.products);
    }
    _notify();
  }

  Future<void> _loadFirstPage() async {
    final generation = ++_generation;
    final (message, page) = await _repository.fetchPage(skip: 0);
    if (generation != _generation) return;

    _isLoadingMore = false;
    _loadMoreError = null;

    if (page == null) {
      // Keep what is already on screen when a refresh fails.
      if (_products.isEmpty) {
        _errorMessage = message;
      } else {
        AppMessenger.showError(message);
      }
    } else {
      _errorMessage = null;
      _total = page.total;
      _products
        ..clear()
        ..addAll(page.products);
    }
    _notify();
  }

  // Requests can finish after the screen is gone, e.g. after logging out.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
