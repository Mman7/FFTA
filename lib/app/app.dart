import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/rooms/presentation/pages/rooms_page.dart';
import 'theme/app_theme.dart';

class FlowMoneyApp extends StatelessWidget {
  const FlowMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlowMoney',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: GoRouter(
        initialLocation: '/rooms',
        routes: [
          GoRoute(
            path: '/rooms',
            builder: (context, state) => const RoomsPage(),
          ),
        ],
      ),
    );
  }
}
