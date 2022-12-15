import 'package:flutter/cupertino.dart';

import '../models/cat.dart';

class CatView extends StatelessWidget {
  const CatView({super.key,  required this.cat });
  final Cat cat;

  String get name => cat.name;

  @override
  Widget build(BuildContext context) {
    return Text("I'm a cat my name is $name");
  }
}
