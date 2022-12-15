import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taboo/pages/taboo_page.dart';
import 'package:taboo/tabs/static_tab.dart';
import 'package:taboo/tabs/taboo_tab.dart';
import '../tabs/document_tab.dart';

typedef TabDeserializer = TabooTab Function(Map<String, dynamic>);

class _EmptyStateTab extends StaticTab {
  _EmptyStateTab({ required this.key, this.child });

  Widget? child;

  @override
  Icon? get icon => null;

  @override
  ValueKey key;

  @override
  Page get page => TabooPage(key: key, child: child);

  @override
  bool get showInPageBar => false;

  @override
  String get title => "";

  @override
  bool get persist => false;

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

/// This service is in charge of the any actions made on the documents.
class TabService {

  factory TabService() {
    return _singleton;
  }
  TabService._internal();

  final GlobalKey<NavigatorState>? navigatorKey = GlobalKey();
  static final TabService _singleton = TabService._internal();
  static const String _stateKey = 'TabServiceState';

  final List<TabooTab> openedTabs = [];
  final Map<ValueKey, DateTime> _pageTimestamps = {};
  final BehaviorSubject pagesRx = BehaviorSubject.seeded([]);
  final BehaviorSubject pageBarRx = BehaviorSubject.seeded([]);

  ValueKey? activeTabKey;
  String? openedProject;
  TabDeserializer? deserializer;
  Widget? emptyState;

  TabooTab? get activePage {
    try {
      return openedTabs.firstWhere((element) => element.key == activeTabKey);
    } catch(error) {
      return null;
    }
  }

  Future initialize({ TabDeserializer? deserializer, Widget? emptyState }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    deserializer = deserializer;
    final String? rawState = preferences.getString(_stateKey);
    if (rawState != null) {
      Map<String, dynamic> json = jsonDecode(rawState);
      activeTabKey = json.containsKey('activeTabKey') ? ValueKey(json['activeTabKey']) : null;

      if (json.containsKey('openedTabs')) {
        openedTabs.clear();
        if (deserializer != null) {
          openedTabs.addAll((jsonDecode(json['openedTabs']) as List).map((e) => deserializer!.call(e)).toList());
        }
      }

      if (json.containsKey('pageTimestamps')) {
        _pageTimestamps.clear();
        _pageTimestamps.addAll((jsonDecode(json['pageTimestamps']) as Map).map<ValueKey, DateTime>((key, value) => MapEntry(ValueKey(key), DateTime.parse(value))));
      }

      if (json.containsKey('openedProject')) {
        openedProject = json['openedProject'];
      }
    }
  }

  Future save() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(_stateKey, jsonEncode(toJson()));
  }

  void refreshPages() {
    pagesRx.add(openedTabs);
  }

  void markCurrentDocumentAsUnsaved() {
    if (activePage != null && activePage is DocumentTab) {
      (activePage as DocumentTab).isSaved = false;
      pageBarRx.add(openedTabs);
    }
  }

  void reorderTab(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final TabooTab item = openedTabs.removeAt(oldIndex);
    openedTabs.insert(newIndex, item);
    pagesRx.add(openedTabs);
  }

  void openTab(TabooTab tab, { DateTime? timestamp, int? index }) {
    if (!openedTabs.contains(tab)) {
      if (index != null) {
        openedTabs.insert(index, tab);
      } else {
        openedTabs.add(tab);
      }
    } else {
      if (tab is DocumentTab) {
        tab = openedTabs.whereType<DocumentTab>()
          .firstWhere((element) => element == tab);
      }
    }

    activeTabKey = tab.key;
    _pageTimestamps[tab.key] = timestamp ?? DateTime.now();
    pagesRx.add(openedTabs);
    save();
  }

  void closePage(TabooTab page) {
    openedTabs.remove(page);
    // We need to select the adjacent tab since this will be the
    // tab that will be shown in the content area of the app after the closure
    // of the active tab.
    if (openedTabs.isNotEmpty) {
      activeTabKey = getSortedTabs().last.key;
    }
    _pageTimestamps.remove(page.key);
    pagesRx.add(openedTabs);
    save();
  }

  T? getPageByKey<T extends TabooTab>(LocalKey key) {
    return openedTabs.firstWhere((element) => element is T && element.key == key) as T;
  }

  bool replacePage(LocalKey oldPageKey, TabooTab newPage) {
    int index = openedTabs.indexWhere((element) => element.key == oldPageKey);
    if (index >= 0) {
      openedTabs[index] = newPage;
      refreshPages();
      return true;
    }

    return false;
  }

  List<TabooTab> getSortedTabs() {
    List<TabooTab> tabs = List.of(openedTabs)..sort((pageA, pageB) {
      DateTime? pageATimestamp = _pageTimestamps[pageA.key];
      DateTime? pageBTimestamp = _pageTimestamps[pageB.key];

      if (pageATimestamp != null && pageBTimestamp != null) {
        return pageATimestamp.compareTo(pageBTimestamp);
      }

      throw Exception("Bodistics page was found without a timestamp");
    });
    return tabs;
  }

  List<MaterialPage> getPageStack() {
    final List<TabooTab> tabs = getSortedTabs();
    tabs.insert(0, _EmptyStateTab(
        key: const ValueKey('EmptyStateTab'),
        child: emptyState));
    return tabs.map<MaterialPage>((tab) => tab.page as MaterialPage).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'openedTabs': jsonEncode(openedTabs
          .where((e) => e.persist)
          .map((e) => e.toJson()).toList()),
      'activeTabKey': activeTabKey?.value,
      'pageTimestamps': jsonEncode(_pageTimestamps.map<String, String>((key, value) => MapEntry(key.value, value.toIso8601String()))),
      'openedProject': openedProject
    };
  }
}