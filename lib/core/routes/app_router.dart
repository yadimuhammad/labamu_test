import 'package:go_router/go_router.dart';

import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/product/presentation/pages/product_form_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ProductListPage()),
      ),
      GoRoute(
        path: '/products/new',
        name: 'product_add',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ProductFormPage()),
      ),
      GoRoute(
        path: '/products/:id',
        name: 'product_detail',
        pageBuilder: (context, state) => NoTransitionPage(
          child: ProductDetailPage(id: state.pathParameters['id']!),
        ),
      ),
      // GoRoute(
      //   path: '/products/:id/edit',
      //   builder: (context, state) {
      //     final product = state.extra as Product?;
      //     return ProductFormPage(product: product);
      //   },
      // ),
    ],
  );
}
