import 'package:flutter/material.dart';
import '../main.dart';
import '../models/stroke.dart';
import '../models/text_data.dart';
import '../models/arrow_data.dart';
import '../models/shape_data.dart';
import '../models/shape_type.dart';
import '../models/drawing_action.dart';
import '../painters/drawing_painter.dart';
import '../utils/responsive_utils.dart';
import '../widgets/toolbar/toolbar_button.dart';
import '../widgets/toolbar/color_button.dart';
import '../widgets/toolbar/stroke_button.dart';
import '../widgets/toolbar/shape_button.dart';
import '../widgets/toolbar/undo_button.dart';
import '../widgets/toolbar/redo_button.dart';
import '../widgets/dialogs/text_dialog.dart';
import '../widgets/dialogs/text_options_dialog.dart';
import '../widgets/dialogs/edit_text_dialog.dart';

class DrawingBoardUI extends StatefulWidget {
  @override
  _DrawingBoardUIState createState() => _DrawingBoardUIState();
}

class _DrawingBoardUIState extends State<DrawingBoardUI> {
  bool isTextDialogActive = false;
  String? activeBar = 'pen'; // Default active tool is 'pen'
  bool isPenActive = true;
  bool isShapeActive = false;
  bool isStrokeActive = false;
  bool isColorActive = false;
  bool isArrowActive = false; // Track arrow state
  bool isDarkMode = false; // Theme switch state

  List<Stroke> strokes = [];
  List<Offset> currentStrokePoints = [];
  bool isDrawing = false;
  double currentStrokeWidth = 4.0;
  late Color currentColor; // Will change based on theme
  List<TextData> texts = [];
  List<ArrowData> arrows = [];
  List<ShapeData> shapes = [];
  ShapeType? selectedShape;
  Offset? shapeStart;
  Offset? shapeEnd;

  List<DrawingAction> undoStack = [];
  List<DrawingAction> redoStack = [];

  late double toolbarWidth;
  late double iconSize;
  late double bottomBarHeight;
  late double strokeWidth;
  late double spacing;

  @override
  void initState() {
    super.initState();
    _initializeResponsiveValues();
    currentColor =
        Colors.black; // Default to black (will update in didChangeDependencies)
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white; // Update based on theme
    _updateDrawingColorsBasedOnTheme(); // Ensure drawings update on theme change
  }

  void _initializeResponsiveValues() {
    final values = ResponsiveUtils.initializeResponsiveValues();
    toolbarWidth = values['toolbarWidth']!;
    iconSize = values['iconSize']!;
    bottomBarHeight = values['bottomBarHeight']!;
    strokeWidth = values['strokeWidth']!;
    spacing = values['spacing']!;
  }

  void _updateResponsiveValues(BuildContext context) {
    ResponsiveUtils.updateResponsiveValues(context, setState);
    final values = ResponsiveUtils.initializeResponsiveValues();
    toolbarWidth = values['toolbarWidth']!;
    iconSize = values['iconSize']!;
    bottomBarHeight = values['bottomBarHeight']!;
    strokeWidth = values['strokeWidth']!;
    spacing = values['spacing']!;
  }

  void toggleBar(String bar) {
    setState(() {
      // Only reset drawing tool states if explicitly changing to another drawing tool
      if (bar == 'pen' || bar == 'shape' || bar == 'arrow') {
        isPenActive = false;
        isShapeActive = false;
        isArrowActive = false;
      }
      // Do not reset drawing tool states for stroke, color, text, or clear
      isStrokeActive = bar == 'stroke';
      isColorActive = bar == 'color';

      switch (bar) {
        case 'pen':
          isPenActive = true;
          activeBar = 'pen';
          break;
        case 'shape':
          isShapeActive = true;
          activeBar = 'shape';
          break;
        case 'stroke':
          isStrokeActive = true;
          activeBar = 'stroke';
          break;
        case 'color':
          isColorActive = true;
          activeBar = 'color';
          break;
        case 'text':
          activeBar = 'text';
          break;
        case 'arrow':
          isArrowActive = true;
          activeBar = 'arrow';
          break;
        case 'clear':
          clearDrawing();
          break;
      }
    });
  }

  void selectShape(ShapeType shape) {
    setState(() {
      selectedShape = shape;
      isShapeActive = true;
      isPenActive = false;
      isArrowActive = false; // Deactivate arrow when selecting shape
      activeBar = 'shape';
    });
  }

  void startDrawing(Offset point) {
    setState(() {
      isDrawing = true;
      if (isPenActive) {
        currentStrokePoints = [];
        currentStrokePoints.add(point);
      } else if (isShapeActive) {
        shapeStart = point;
        shapeEnd = point;
      } else if (isArrowActive) {
        currentStrokePoints = [];
        currentStrokePoints.add(point);
      }
    });
  }

  void updateDrawing(Offset point) {
    if (isDrawing) {
      setState(() {
        if (isPenActive) {
          currentStrokePoints.add(point);
        } else if (isShapeActive) {
          shapeEnd = point;
        } else if (isArrowActive) {
          currentStrokePoints.add(point);
        }
      });
    }
  }

  void stopDrawing() {
    setState(() {
      isDrawing = false;
      if (isPenActive && currentStrokePoints.isNotEmpty) {
        final stroke = Stroke(
          points: List.from(currentStrokePoints),
          color: currentColor,
          strokeWidth: currentStrokeWidth,
        );
        strokes.add(stroke);
        undoStack.add(DrawingAction.fromStroke(stroke));
        redoStack.clear();
        currentStrokePoints.clear();
      } else if (isShapeActive && shapeStart != null && shapeEnd != null) {
        final shape = ShapeData(
          shapeType: selectedShape!,
          start: shapeStart!,
          end: shapeEnd!,
          color: currentColor,
          strokeWidth: currentStrokeWidth,
        );
        shapes.add(shape);
        undoStack.add(DrawingAction.fromShape(shape));
        redoStack.clear();
        shapeStart = null;
        shapeEnd = null;
      } else if (isArrowActive && currentStrokePoints.length >= 2) {
        final arrow = ArrowData(
          start: currentStrokePoints.first,
          end: currentStrokePoints.last,
          color: currentColor,
          strokeWidth: currentStrokeWidth,
        );
        arrows.add(arrow);
        undoStack.add(DrawingAction.fromArrow(arrow));
        redoStack.clear();
        currentStrokePoints.clear();
      }
    });
  }

  void clearDrawing() {
    setState(() {
      strokes.clear();
      texts.clear();
      arrows.clear();
      shapes.clear();
      undoStack.clear();
      redoStack.clear();
    });
  }

  void setStrokeWidth(double width) {
    setState(() {
      currentStrokeWidth = width;
      // Explicitly do NOT change activeBar, isPenActive, isShapeActive, or isArrowActive
      // Maintain the current drawing tool (pen, shape, or arrow) as active
    });
  }

  void setColor(Color color) {
    setState(() {
      currentColor = color;
      // Explicitly do NOT change activeBar, isPenActive, isShapeActive, or isArrowActive
      // Maintain the current drawing tool (pen, shape, or arrow) as active
    });
  }

  void addText(Offset position, String text) {
    setState(() {
      final textData = TextData(
        text: text,
        position: position,
        color: currentColor,
      );
      texts.add(textData);
      undoStack.add(DrawingAction.fromText(textData));
      redoStack.clear();
    });
  }

  void addArrow(Offset start, Offset end) {
    setState(() {
      final arrow = ArrowData(
        start: start,
        end: end,
        color: currentColor,
        strokeWidth: currentStrokeWidth,
      );
      arrows.add(arrow);
      undoStack.add(DrawingAction.fromArrow(arrow));
      redoStack.clear();
    });
  }

  void undo() {
    if (undoStack.isEmpty) return;
    setState(() {
      final lastAction = undoStack.removeLast();
      switch (lastAction.type) {
        case ActionType.stroke:
          strokes.remove(lastAction.action as Stroke);
          break;
        case ActionType.text:
          texts.remove(lastAction.action as TextData);
          break;
        case ActionType.arrow:
          arrows.remove(lastAction.action as ArrowData);
          break;
        case ActionType.shape:
          shapes.remove(lastAction.action as ShapeData);
          break;
      }
      redoStack.add(lastAction);
    });
  }

  void redo() {
    if (redoStack.isEmpty) return;
    setState(() {
      final lastUndoneAction = redoStack.removeLast();
      switch (lastUndoneAction.type) {
        case ActionType.stroke:
          strokes.add(lastUndoneAction.action as Stroke);
          break;
        case ActionType.text:
          texts.add(lastUndoneAction.action as TextData);
          break;
        case ActionType.arrow:
          arrows.add(lastUndoneAction.action as ArrowData);
          break;
        case ActionType.shape:
          shapes.add(lastUndoneAction.action as ShapeData);
          break;
      }
      undoStack.add(lastUndoneAction);
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _updateDrawingColorsBasedOnTheme1(); // Update all drawings when theme changes
      currentColor =
          isDarkMode ? Colors.white : Colors.black; // Switch paint color
      MyAppState? appState = context.findAncestorStateOfType<MyAppState>();
      appState?.toggleTheme(isDarkMode);
    });
  }

  void _updateDrawingColorsBasedOnTheme1() {
    setState(() {
      final isLight = !isDarkMode;
      // Update strokes
      for (var stroke in strokes) {
        stroke = Stroke(
          points: stroke.points,
          color: isLight ? Colors.black : Colors.white,
          strokeWidth: stroke.strokeWidth,
        );
      }
      // Update shapes
      for (var shape in shapes) {
        shape = ShapeData(
          shapeType: shape.shapeType,
          start: shape.start,
          end: shape.end,
          color: isLight ? Colors.black : Colors.white,
          strokeWidth: shape.strokeWidth,
        );
      }
      // Update arrows
      for (var arrow in arrows) {
        arrow = ArrowData(
          start: arrow.start,
          end: arrow.end,
          color: isLight ? Colors.black : Colors.white,
          strokeWidth: arrow.strokeWidth,
        );
      }
      // Update texts
      for (var text in texts) {
        text = TextData(
          text: text.text,
          position: text.position,
          color: isLight ? Colors.black : Colors.white,
          isDragging: text.isDragging,
          isSelected: text.isSelected,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateResponsiveValues(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Drawing Board",
          style: TextStyle(
            color: isDarkMode
                ? Colors.white
                : Colors.white, // White in both themes for consistency
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode
            ? Color(0xFF1A2526)
            : Color(0xFF4A90E2), // Bright blue in light, deep teal in dark
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.yellow : Colors.white,
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                _buildMainLayout(constraints, isPortrait),
                if (activeBar != null &&
                    ['stroke', 'color', 'shape'].contains(activeBar!))
                  _buildToolOptions(activeBar!, constraints, isPortrait),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainLayout(BoxConstraints constraints, bool isPortrait) {
    return isPortrait
        ? _buildPortraitLayout(constraints)
        : _buildLandscapeLayout(constraints);
  }

  Widget _buildPortraitLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Container(
          width: toolbarWidth,
          height: constraints.maxHeight,
          color: isDarkMode
              ? Color(0xFF1A2526)
              : Color(0xFFF7F9FC), // Light grey in light, deep grey in dark
          child: _buildToolbar(false, constraints),
        ),
        Expanded(
          child: _buildCanvas(constraints),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Container(
          width: toolbarWidth,
          color: isDarkMode
              ? Color(0xFF1A2526)
              : Color(0xFFF7F9FC), // Light grey in light, deep grey in dark
          child: _buildToolbar(false, constraints),
        ),
        Expanded(
          child: _buildCanvas(constraints),
        ),
      ],
    );
  }

  Widget _buildToolbar(bool isLandscape, BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _buildToolbarButtons(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildToolbarButtons() {
    return [
      _buildToolbarButton(Icons.brush, "Pen", 'pen'),
      _buildToolbarButton(Icons.crop_square, "Shape", 'shape'),
      _buildToolbarButton(Icons.circle, "Stroke", 'stroke'),
      _buildToolbarButton(Icons.palette, "Color", 'color'),
      _buildToolbarButton(Icons.text_fields, "Text", 'text'),
      _buildToolbarButton(Icons.arrow_forward, "Arrow", 'arrow'),
      UndoButton(onTap: undo, isEnabled: undoStack.isNotEmpty),
      RedoButton(onTap: redo, isEnabled: redoStack.isNotEmpty),
      _buildToolbarButton(Icons.clear, "Clear", 'clear'),
    ];
  }

  Widget _buildToolbarButton(IconData icon, String label, String value) {
    final bool isActive = activeBar == value;
    final Color iconColor = isDarkMode
        ? (isActive ? Colors.white : Colors.white70)
        : (isActive ? Color(0xFF4A90E2) : Colors.black87);
    final Color textColor = isDarkMode
        ? (isActive ? Colors.white : Colors.white70)
        : (isActive ? Color(0xFF4A90E2) : Colors.black87);

    return GestureDetector(
      onTap: () => value == 'clear' ? clearDrawing() : toggleBar(value),
      child: Container(
        width: toolbarWidth,
        padding: EdgeInsets.symmetric(vertical: spacing),
        decoration: BoxDecoration(
          color: isActive
              ? (isDarkMode
                  ? Color(0xFF2D4A52)
                  : Color(0xFF4A90E2).withOpacity(0.2))
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
            SizedBox(height: spacing / 2),
            Text(
              label,
              style: TextStyle(
                fontSize: iconSize * 0.4,
                color: textColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolOptions(
      String type, BoxConstraints constraints, bool isPortrait) {
    if (!['stroke', 'color', 'shape'].contains(type)) {
      return SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: toolbarWidth,
      right: 0,
      child: Container(
        height: 60,
        color: isDarkMode
            ? Color(0xFF1A2526).withOpacity(0.1)
            : Color(0xFFF7F9FC), // Flat background, no shadow
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildOptionsForType(type).map((widget) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: widget,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptionsForType(String type) {
    switch (type) {
      case 'stroke':
        return [2, 4, 6, 8]
            .map((width) => StrokeButton(
                  label: width.toString(),
                  onTap: () => setStrokeWidth(width.toDouble()),
                ))
            .toList();
      case 'color':
        return [Colors.black, Colors.red, Colors.blue, Colors.green]
            .map((color) => ColorButton(
                  color: color,
                  onTap: () => setColor(color),
                ))
            .toList();
      case 'shape':
        return [
          (Icons.crop_square, "Rectangle", ShapeType.rectangle),
          (Icons.circle, "Circle", ShapeType.circle),
          (Icons.linear_scale, "Line", ShapeType.line),
          (Icons.change_history, "Triangle", ShapeType.triangle),
        ]
            .map((shape) => ShapeButton(
                  icon: shape.$1,
                  label: shape.$2,
                  onTap: () => selectShape(shape.$3),
                ))
            .toList();
      default:
        return [];
    }
  }

  Widget _buildCanvas(BoxConstraints constraints) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            if (activeBar == 'text' && !isTextDialogActive) {
              setState(() {
                isTextDialogActive = true;
              });
              showTextDialog(context, details.localPosition, addText,
                  setState: setState, isTextDialogActive: isTextDialogActive);
            }
          },
          onPanStart: (details) => _handlePanStart(details),
          onPanUpdate: (details) => _handlePanUpdate(details),
          onPanEnd: (details) => _handlePanEnd(details),
          child: CustomPaint(
            size: Size.infinite,
            painter: DrawingPainter(
              strokes: strokes,
              currentStrokePoints: currentStrokePoints,
              currentColor: currentColor,
              currentStrokeWidth: currentStrokeWidth,
              texts: texts,
              arrows: arrows,
              shapes: shapes,
              shapeStart: shapeStart,
              shapeEnd: shapeEnd,
              selectedShape: selectedShape,
            ),
          ),
        ),
        ...texts.map((textData) {
          return Positioned(
            left: textData.position.dx,
            top: textData.position.dy,
            child: GestureDetector(
              onTap: () => showTextOptions(context, textData, (textData) {
                showEditTextDialog(context, textData, setState);
              }, (callback) {
                setState(() {
                  texts.remove(textData);
                  undoStack.add(DrawingAction.fromText(textData));
                  redoStack.clear();
                });
              }),
              onPanStart: (_) {
                setState(() {
                  textData.isDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  textData.position = Offset(
                    textData.position.dx + details.delta.dx,
                    textData.position.dy + details.delta.dy,
                  );
                });
              },
              onPanEnd: (_) {
                setState(() {
                  textData.isDragging = false;
                });
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: textData.isDragging || textData.isSelected
                      ? (isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  textData.text,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _handlePanStart(DragStartDetails details) {
    if (isPenActive || isShapeActive || isArrowActive) {
      startDrawing(details.localPosition);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (isPenActive || isShapeActive || isArrowActive) {
      updateDrawing(details.localPosition);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (isPenActive || isShapeActive || isArrowActive) {
      stopDrawing();
    }
  }

  void _updateDrawingColorsBasedOnTheme() {
    setState(() {
      final isLight = !isDarkMode;
      // Update strokes
      for (var stroke in strokes) {
        stroke = Stroke(
          points: stroke.points,
          color: isLight ? Colors.black : Colors.white,
          strokeWidth: stroke.strokeWidth,
        );
      }
      // Update shapes
      for (var shape in shapes) {
        shape = ShapeData(
          shapeType: shape.shapeType,
          start: shape.start,
          end: shape.end,
          color: isLight ? Colors.black : Colors.white,
          strokeWidth: shape.strokeWidth,
        );
      }
      // Update arrows
      for (var arrow in arrows) {
        arrow = ArrowData(
          start: arrow.start,
          end: arrow.end,
          color: isLight ? Colors.black : Colors.white,
          strokeWidth: arrow.strokeWidth,
        );
      }
      // Update texts
      for (var text in texts) {
        text = TextData(
          text: text.text,
          position: text.position,
          color: isLight ? Colors.black : Colors.white,
          isDragging: text.isDragging,
          isSelected: text.isSelected,
        );
      }
    });
  }
}
