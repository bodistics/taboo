import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:taboo/tabs/taboo_tab.dart';
import 'package:taboo/views/tab/taboo_tab_view.dart';

import '../../service/tab_service.dart';
import '../../tabs/document_tab.dart';

typedef PageHandler = void Function(TabooTab);
typedef CloseUnsavedRequest = Future<bool> Function(DocumentTab);
typedef TabBuilder = Widget Function(TabooTab);

class TabooBar extends StatelessWidget {
  const TabooBar({
    Key? key,
    required this.controller,
    this.builder,
    this.onCloseUnsaved,
  }) : super(key: key);

  final TabooController controller;
  final TabBuilder? builder;
  final CloseUnsavedRequest? onCloseUnsaved;

  List<TabooTab> get tabs => controller.openedTabs;

  @override
  Widget build(BuildContext context) {
    Color? unselectedColor = Theme.of(context).tabBarTheme.unselectedLabelColor;
    Color? selectedTabColor = Theme.of(context).tabBarTheme.labelColor;
    Color? barColor = Theme.of(context).colorScheme.surface;

    return StreamBuilder(
      stream: controller.tabBarRx,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
            alignment: Alignment.centerLeft,
            color: barColor,
            height: 35,
            child: tabs.isEmpty
                ? Container()
                : ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                dragStartBehavior: DragStartBehavior.start,
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final TabooTab tab = tabs[index];
                  return StreamBuilder(
                      key: tab.key,
                      stream: tab.listener,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return ReorderableDragStartListener(
                            index: index,
                            child: builder?.call(tab) ??
                              TabooTabView(
                                tab: tab,
                                isActive: tab == controller.activeTab,
                                onCloseUnsaved: onCloseUnsaved,
                                onTabClose: controller.closeTab,
                                onTabTap: controller.openTab,
                              )
                        );
                      }
                  );
                },
                onReorder: controller.reorderTab
            )
        );
      }
    );
  }
}