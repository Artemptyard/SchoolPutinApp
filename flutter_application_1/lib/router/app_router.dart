import 'package:go_router/go_router.dart';
import '../features/login_page.dart';
import '../features/main_layout.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => MainLayout(userRole: 'teacher'),
        routes: [ /* подмаршруты учителя */ ],
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => MainLayout(userRole: 'student'),
        routes: [ /* подмаршруты ученика */ ],
      ),
      GoRoute(
        path: '/parent',
        builder: (context, state) => MainLayout(userRole: 'parent'),
        routes: [ /* подмаршруты родителя */ ],
      ),
    ],
  );
}
