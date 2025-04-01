import 'package:go_router/go_router.dart';

import '../../feature/presentation/splash/splash_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (_, GoRouterState state) {
        return const SplashScreen();
      },
    ),

    /// Auth route
  ],
);
