import 'stroke.dart';
import 'text_data.dart';
import 'arrow_data.dart';
import 'shape_data.dart';

enum ActionType { stroke, text, arrow, shape }

class DrawingAction {
  final ActionType type;
  final dynamic action;

  DrawingAction({required this.type, required this.action});

  static DrawingAction fromStroke(Stroke stroke) {
    return DrawingAction(type: ActionType.stroke, action: stroke);
  }

  static DrawingAction fromText(TextData text) {
    return DrawingAction(type: ActionType.text, action: text);
  }

  static DrawingAction fromArrow(ArrowData arrow) {
    return DrawingAction(type: ActionType.arrow, action: arrow);
  }

  static DrawingAction fromShape(ShapeData shape) {
    return DrawingAction(type: ActionType.shape, action: shape);
  }
}
