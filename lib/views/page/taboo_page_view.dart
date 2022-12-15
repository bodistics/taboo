import 'package:flutter/material.dart';
import 'package:taboo/service/tab_service.dart';

class TabooPageView<T> extends RouterDelegate<T>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<T> {
  final TabService _tabService = TabService();
  final HeroController _heroController = HeroController();

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope.none(
        child: Navigator(
          observers: [_heroController],
          key: _tabService.navigatorKey,
          onGenerateRoute:
              (RouteSettings route) {
            return null;
          },
          onPopPage: (route, result) {
            return true;
          },
          pages: TabService().getPageStack()
        )
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _tabService.navigatorKey;

  @override
  Future<void> setNewRoutePath(T configuration) {
    return Future.value(null);
  }

  @override
  Future<void> setInitialRoutePath(T configuration) {
    return super.setInitialRoutePath(configuration);
  }
}
