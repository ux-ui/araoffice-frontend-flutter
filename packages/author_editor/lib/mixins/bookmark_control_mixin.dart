//bookmark control mixin

import 'package:author_editor/engine/engines.dart';
import 'package:author_editor/engine/extension_js_type/js_editor_types.dart';

mixin BookmarkControlMixin {
  Editor? get editor;

  void insertBookmark(String name) {
    editor?.insertBookmark(name);
  }

  void getBookmarks() {
    editor?.getBookmarks();
  }

  void selectBookmark(String name) {
    editor?.selectBookmark(name);
  }

  void removeBookmark(String name) {
    editor?.removeBookmark(name);
  }
}
