import 'package:flutter/material.dart';

import '../../service/tab_service.dart';
import '../../tabs/document_tab.dart';
import '../../tabs/taboo_tab.dart';
import '../bar/taboo_bar.dart';

class TabooTabView extends StatelessWidget {

  const TabooTabView({super.key,
    required this.tab,
    this.onCloseUnsaved,
    this.onTabClose,
    this.onTabTap });

  final TabooTab tab;
  final PageHandler? onTabTap;
  final PageHandler? onTabClose;
  final CloseUnsavedRequest? onCloseUnsaved;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: tab.key == TabService().activeTabKey
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
        constraints: const BoxConstraints(
          maxWidth: 250,
          maxHeight: 35,
        ),
        alignment: Alignment.centerLeft,
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          selectedTileColor: Theme.of(context).colorScheme.onPrimary,
          tileColor: Theme.of(context).colorScheme.onPrimary,
          contentPadding: EdgeInsets.zero,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10.0),
              ),
              if (tab.icon != null)
                Container(
                    alignment: const Alignment(-1.0, -.3),
                    padding: const EdgeInsets.only(right: 15.0),
                    child: tab.icon!
                ),
              if (tab is DocumentTab && !(tab as DocumentTab).isSaved)
                Text("* ",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 170,
                  maxHeight: 35,
                ),
                child: Text(
                    tab.title,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    softWrap: true,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  constraints: const BoxConstraints(
                      minWidth: 45
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, size: 14.0, color: Theme.of(context).colorScheme.onPrimary,),
                    onPressed: () async {
                      if (onTabClose != null) {
                        bool closeTab = true;
                        if (tab is DocumentTab && !(tab as DocumentTab).isSaved) {
                          closeTab = await onCloseUnsaved?.call(tab as DocumentTab) ?? true;
                        }
                        if (closeTab) {
                          onTabClose!(tab);
                        }
                      }
                    },
                  ),
                ),
              ),

            ],
          ),
          selected: true,
          onTap: () {
            if (onTabTap != null) {
              onTabTap!(tab);
            }
          },
        )
    );
  }
}
