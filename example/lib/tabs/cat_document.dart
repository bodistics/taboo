import 'package:example/models/cat.dart';
import 'package:example/views/cat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/icon.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:taboo/pages/taboo_page.dart';
import 'package:taboo/tabs/document_tab.dart';

class CatDocument extends DocumentTab<Cat> {
  CatDocument({ required this.cat }) : super(isSaved: false);
  final Cat cat;

  @override
  Icon? get icon => const Icon(Icons.pets);

  @override
  ValueKey get key => ValueKey(cat.name);

  @override
  Page get page => TabooPage(key: key, name: cat.name, child: CatView(cat: state));

  @override
  bool get persist => false;

  @override
  bool get showInPageBar => true;

  @override
  Cat get state => cat;

  @override
  String get title => cat.name;

  @override
  Map<String, dynamic> toJson() {
    // You only have to implement this if the "persist" property is set to true..
    throw Exception("not implemented...");
  }
}
