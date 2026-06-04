import 'package:go_router/go_router.dart';
import 'package:safed_prixod/features/auth/login_page.dart';
import 'package:safed_prixod/features/notifications/staff_notifications_page.dart';
import 'package:safed_prixod/features/orders/order_check_page.dart';
import 'package:safed_prixod/features/orders/picking_detail_page.dart';
import 'package:safed_prixod/features/orders/picking_orders_page.dart';
import 'package:safed_prixod/features/posts/post_detail_page.dart';
import 'package:safed_prixod/features/posts/post_form_page.dart';
import 'package:safed_prixod/features/posts/posts_list_page.dart';
import 'package:safed_prixod/features/products/product_detail_page.dart';
import 'package:safed_prixod/features/products/product_form_page.dart';
import 'package:safed_prixod/features/products/products_list_page.dart';
import 'package:safed_prixod/features/shell/prixod_shell.dart';

GoRouter createPrixodRouter({required bool loggedIn}) {
  return GoRouter(
    initialLocation: loggedIn ? '/orders' : '/login',
    redirect: (_, state) {
      final loc = state.matchedLocation;
      if (!loggedIn && loc != '/login') return '/login';
      if (loggedIn && loc == '/login') return '/orders';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const StaffNotificationsPage(),
      ),
      GoRoute(
        path: '/orders/:id/check',
        builder: (_, state) => OrderCheckPage(
          orderId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) => PickingDetailPage(
          orderId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/products/new',
        builder: (_, __) => const ProductFormPage(),
      ),
      GoRoute(
        path: '/products/:id/edit',
        builder: (_, state) => ProductFormPage(
          productId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (_, state) => ProductDetailPage(
          productId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/posts/new',
        builder: (_, __) => const PostFormPage(),
      ),
      GoRoute(
        path: '/posts/:id/edit',
        builder: (_, state) => PostFormPage(
          postId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/posts/:id',
        builder: (_, state) => PostDetailPage(
          postId: int.parse(state.pathParameters['id']!),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            PrixodShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (_, __) => const PickingOrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (_, __) => const ProductsListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/posts',
                builder: (_, __) => const PostsListPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
