import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
typedef PageBuilder = Widget Function(BuildContext context, LocalKey pageKey);

abstract class TabooTab {
  TabooTab();
  BehaviorSubject listener = BehaviorSubject();

  bool get persist;
  bool get showInPageBar;
  ValueKey get key;
  String get title;
  Icon? get icon;
  Page get page;

  Map<Type, Action<Intent>>? get actions => null;
  Map<ShortcutActivator, Intent>? get shortcuts => null;

  @override
  bool operator ==(Object other) {
    if (other is TabooTab) {
      return other.key == key;
    }
    return false;
  }

  void notifyChange() {
    listener.add(this);
  }

  Map<String, dynamic> toJson();

  @override
  int get hashCode => key.hashCode;
}
