import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_page.dart';
import '../features/curriculum/indicator_browser_page.dart';
import '../features/curriculum/indicator_resources_page.dart';
import '../features/favorites/favorites_page.dart';
import '../features/home/home_page.dart';
import '../features/library/library_page.dart';
import '../features/profile/profile_page.dart';
import '../features/publish/publish_page.dart';
import '../features/publish/upload_form_page.dart';
import '../features/resource/resource_detail_page.dart';
import '../widgets/shell_scaffold.dart';

/// 每次呼叫建立一個新的 router,測試之間才不會共用導覽狀態。
GoRouter createAppRouter() {
  // 讓 push 出來的頁面(詳情、登入、投稿)也反映在網址列:瀏覽器「上一頁」才會
  // 正確回到前一頁,而不是跳到更早的分頁;詳情頁網址也能直接分享。
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(shell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/publish',
              builder: (context, state) => const PublishPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
      // 詳情頁蓋在底部導覽之上(全螢幕)
      GoRoute(
        path: '/resource/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            ResourceDetailPage(resourceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/publish/new',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const UploadFormPage(),
      ),
      GoRoute(
        path: '/indicators',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const IndicatorBrowserPage(),
      ),
      GoRoute(
        path: '/indicators/:code',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => IndicatorResourcesPage(
            indicatorCode: state.pathParameters['code']!),
      ),
    ],
  );
}
