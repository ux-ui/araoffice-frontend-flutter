import 'dart:js_interop';

@JS()
// NodeRect 인터페이스를 위한 extension type 정의
extension type NodeRect(JSObject _) implements JSObject {
  external JSObject get node; // Node 타입은 JSObject로 처리
  external JSNumber? get left; // optional number -> nullable JSNumber
  external JSNumber? get top;
  external JSNumber get width;
  external JSNumber get height;
}

// Dart에서 사용할 모델 클래스
class EditorHtmlNodeRect {
  final Object node;
  final double? left;
  final double? top;
  final double width;
  final double height;

  EditorHtmlNodeRect({
    required this.node,
    this.left,
    this.top,
    required this.width,
    required this.height,
  });

  // JS NodeRect를 EditorHtmlNodeRect로 변환하는 팩토리 생성자
  factory EditorHtmlNodeRect.fromJS(NodeRect jsRect) {
    return EditorHtmlNodeRect(
      node: jsRect.node,
      left: jsRect.left?.toDartDouble,
      top: jsRect.top?.toDartDouble,
      width: jsRect.width.toDartDouble,
      height: jsRect.height.toDartDouble,
    );
  }
}
