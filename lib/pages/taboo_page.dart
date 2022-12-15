import 'package:flutter/material.dart';

class TabooPage<T> extends MaterialPage<T>{

  const TabooPage({
    required child,
    maintainState = true,
    fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
    child: child,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId);

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (c, a1, a2) => child,
      transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 0),
      settings: this
    );
  }
}