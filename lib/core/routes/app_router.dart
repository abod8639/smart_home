import 'package:go_router/go_router.dart';
import 'package:smart_home/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:smart_home/features/room/presentation/pages/room_placement_view.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/room-placement',
      builder: (context, state) => const RoomPlacementView(),
    ),
  ],
);
