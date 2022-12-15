import 'package:taboo/tabs/taboo_tab.dart';

/// A DocumentTab is a tab that represents a file in the device. Document tabs
/// can be saved and their state can be restored if the app is closed without
/// saving the pending changes. DocumentTab class is a generic class, this means
/// that you have to specify upon creation of a new DocumentTab subclass the class
/// that is used as a model.
abstract class DocumentTab<T> extends TabooTab {
  DocumentTab({ this.filePath, required this.isSaved });
  bool isSaved;
  String? filePath;
  T get state;
}