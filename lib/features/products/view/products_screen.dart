import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_listing_demo/core/di/service_locator.dart';
import 'package:product_listing_demo/core/routing/app_routes.dart';
import 'package:product_listing_demo/core/widgets/state_view.dart';
import 'package:product_listing_demo/features/auth/repository/auth_repository.dart';
import 'package:product_listing_demo/features/auth/store/auth_session_store.dart';
import 'package:product_listing_demo/features/auth/store/auth_store.dart';
import 'package:product_listing_demo/features/auth/view/widgets/profile_drawer.dart';
import 'package:product_listing_demo/features/auth/view/widgets/user_avatar.dart';
import 'package:product_listing_demo/features/products/store/products_store.dart';
import 'package:product_listing_demo/features/products/view/widgets/product_card.dart';
import 'package:product_listing_demo/features/products/view/widgets/product_card_skeleton.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final _store = context.read<ProductsStore>();

  static const _loadMoreThreshold = 400.0;

  @override
  void initState() {
    super.initState();
    if (context.read<AuthSessionStore>().user == null) locator<AuthRepository>().loadProfile();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < _loadMoreThreshold && _store.loadMoreError == null) {
      _store.loadMore();
    }
    return false;
  }

  void _logout() {
    context.read<AuthStore>().logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthSessionStore>(
          builder: (_, sessionStore, _) {
            final user = sessionStore.user;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Products'),
                if (user != null)
                  Text(
                    'Hi, ${user.firstName}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Profile',
              onPressed: Scaffold.of(context).openEndDrawer,
              icon: Consumer<AuthSessionStore>(builder: (_, sessionStore, _) => UserAvatar(user: sessionStore.user)),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      endDrawer: ProfileDrawer(onLogout: _logout),
      body: Consumer<ProductsStore>(builder: (_, _, _) => _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_store.isLoading && _store.products.isEmpty) {
      return const ProductGridSkeleton();
    }

    final error = _store.errorMessage;
    if (error != null) {
      return _RefreshableState(
        onRefresh: _store.refresh,
        child: StateView(
          icon: Icons.cloud_off_outlined,
          title: 'Could not load products',
          message: error,
          onAction: _store.load,
        ),
      );
    }

    if (_store.isEmpty) {
      return _RefreshableState(
        onRefresh: _store.refresh,
        child: const StateView(
          icon: Icons.inventory_2_outlined,
          title: 'No products yet',
          message: 'Pull down to check again.',
        ),
      );
    }

    final products = _store.products;
    return RefreshIndicator(
      onRefresh: _store.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              sliver: SliverGrid.builder(
                gridDelegate: productGridDelegate(),
                // Two placeholder cards while the next page loads.
                itemCount: products.length + (_store.isLoadingMore ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index >= products.length) return const ProductCardSkeleton();
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    if (_store.loadMoreError != null) {
      return Column(
        children: [
          SizedBox(height: 12.h),
          Text(_store.loadMoreError!, textAlign: TextAlign.center),
          TextButton(onPressed: _store.loadMore, child: const Text('Retry')),
        ],
      );
    }
    if (!_store.hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          'You have seen all ${_store.total} products',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    return SizedBox(height: 24.h);
  }
}

class _RefreshableState extends StatelessWidget {
  const _RefreshableState({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
      ),
    );
  }
}
