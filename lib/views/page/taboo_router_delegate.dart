import 'package:flutter/material.dart';
import 'package:taboo/service/tab_service.dart';

class TabooRouterDelegate<T> extends RouterDelegate<T>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<T> {

  TabooRouterDelegate({ required this.controller });

  final TabooController controller;
  final HeroController _heroController = HeroController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: controller.tabsRx,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return  HeroControllerScope.none(
              child: Navigator(
                  key: controller.navigatorKey,
                  observers: [_heroController],
                  onGenerateRoute:
                      (RouteSettings route) {
                    return null;
                  },
                  onPopPage: (route, result) {
                    return true;
                  },
                  pages: controller.getPageStack()
              )
          );
        }
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => controller.navigatorKey;

  @override
  Future<void> setNewRoutePath(T configuration) {
    return Future.value(null);
  }

  @override
  Future<void> setInitialRoutePath(T configuration) {
    return super.setInitialRoutePath(configuration);
  }
}
