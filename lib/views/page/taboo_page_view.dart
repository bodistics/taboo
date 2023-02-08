import 'package:flutter/cupertino.dart';
import 'package:taboo/taboo.dart';

class TabooPageView extends StatelessWidget {
  const TabooPageView({super.key, required this.controller });

  final TabooController controller;

  @override
  Widget build(BuildContext context) {
    return Router(
        routerDelegate: TabooRouterDelegate(
            controller: controller
        )
    );
  }
}