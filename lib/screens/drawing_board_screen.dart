import 'package:flutter/material.dart';
import '../models/stroke.dart';
import '../models/text_data.dart';
import '../models/arrow_data.dart';
import '../models/shape_data.dart';
import '../models/shape_type.dart';
import '../widgets/toolbar/color_button.dart';
import '../widgets/toolbar/stroke_button.dart';
import '../widgets/toolbar/shape_button.dart';
import '../painters/drawing_painter.dart';
import '../widgets/dialogs/text_dialog.dart';
import '../widgets/dialogs/text_options_dialog.dart';
import '../widgets/dialogs/edit_text_dialog.dart';
import '../utils/responsive_utils.dart';

class DrawingBoardScreen extends StatefulWidget {
  @override
  _DrawingBoardScreenState createState() => _DrawingBoardScreenState();
}

class _DrawingBoardScreenState extends State<DrawingBoardScreen> {
  bool isTextDialogActive = false;
  String? activeBar = 'pen';
  bool isPenActive = true;
  bool isShapeActive = false;
  bool isStrokeActive = false;
  bool isColorActive = false;

  List<Stroke> strokes = [];
  List<Offset> currentStrokePoints = [];
  bool isDrawing = false;
  double currentStrokeWidth = 4.0;
  Color currentColor = Colors.black;
  List<TextData> texts = [];
  List<ArrowData> arrows = [];
  List<ShapeData> shapes = [];
  ShapeType? selectedShape;
  Offset? shapeStart;
  Offset? shapeEnd;

  @override
  void initState() {
    super.initState();
  }

  void toggleBar(String bar) {
    setState(() {
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
          activeBar = 'stroke';
          isStrokeActive = true;
          break;
        case 'color':
          activeBar = 'color';
          isColorActive = true;
          break;
        case 'text':
          activeBar = 'text';
          break;
        case 'arrow':
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
      activeBar = 'shape';
    });
  }

  void startDrawing(Offset point) {
    setState(() {
      isDrawing = true;
      if (activeBar == 'pen') {
        currentStrokePoints = [];
        currentStrokePoints.add(point);
      } else if (activeBar == 'shape') {
        shapeStart = point;
        shapeEnd = point;
      } else if (activeBar == 'arrow') {
        currentStrokePoints = [];
        currentStrokePoints.add(point);
      }
    });
  }

  void updateDrawing(Offset point) {
    if (isDrawing) {
      setState(() {
        if (activeBar == 'pen') {
          currentStrokePoints.add(point);
        } else if (activeBar == 'shape') {
          shapeEnd = point;
        } else if (activeBar == 'arrow') {
          currentStrokePoints.add(point);
        }
      });
    }
  }

  void stopDrawing() {
    setState(() {
      isDrawing = false;

      if (activeBar == 'pen') {
        strokes.add(Stroke(
          points: List.from(currentStrokePoints),
          color: currentColor,
          strokeWidth: currentStrokeWidth,
        ));
        currentStrokePoints.clear();
      } else if (activeBar == 'shape' &&
          shapeStart != null &&
          shapeEnd != null) {
        shapes.add(ShapeData(
          shapeType: selectedShape!,
          start: shapeStart!,
          end: shapeEnd!,
          color: currentColor,
          strokeWidth: currentStrokeWidth,
        ));
        shapeStart = null;
        shapeEnd = null;
      } else if (activeBar == 'arrow') {
        if (currentStrokePoints.length >= 2) {
          addArrow(
            currentStrokePoints.first,
            currentStrokePoints.last,
          );
          currentStrokePoints.clear();
        }
      }
    });
  }

  void clearDrawing() {
    setState(() {
      strokes.clear();
      texts.clear();
      arrows.clear();
      shapes.clear();
    });
  }

  void setStrokeWidth(double width) {
    setState(() {
      currentStrokeWidth = width;
      activeBar = isPenActive
          ? 'pen'
          : isShapeActive
              ? 'shape'
              : activeBar;
      isStrokeActive = false;
    });
  }

  void setColor(Color color) {
    setState(() {
      currentColor = color;
      activeBar = isPenActive
          ? 'pen'
          : isShapeActive
              ? 'shape'
              : activeBar;
      isColorActive = false;
    });
  }

  void addText(Offset position, String text) {
    setState(() {
      texts.add(TextData(
        text: text,
        position: position,
        color: currentColor,
      ));
    });
  }

  void addArrow(Offset start, Offset end) {
    setState(() {
      arrows.add(ArrowData(
        start: start,
        end: end,
        color: currentColor,
        strokeWidth: currentStrokeWidth,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final toolbarWidth = ResponsiveUtils.toolbarWidth(context);
    final iconSize = ResponsiveUtils.iconSize(context);
    final bottomBarHeight = ResponsiveUtils.bottomBarHeight(context);
    final strokeWidth = ResponsiveUtils.strokeWidth(context);
    final spacing = ResponsiveUtils.spacing(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                _buildMainLayout(constraints, toolbarWidth, iconSize,
                    bottomBarHeight, strokeWidth, spacing),
                if (activeBar != null &&
                    ['stroke', 'color', 'shape'].contains(activeBar!))
                  _buildToolOptions(activeBar!, constraints, toolbarWidth,
                      bottomBarHeight, spacing),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainLayout(
      BoxConstraints constraints,
      double toolbarWidth,
      double iconSize,
      double bottomBarHeight,
      double strokeWidth,
      double spacing) {
    return Row(
      children: [
        Container(
          width: toolbarWidth,
          height: constraints.maxHeight,
          child: _buildToolbar(toolbarWidth, iconSize, spacing),
        ),
        Expanded(
          child: _buildCanvas(constraints),
        ),
      ],
    );
  }

  Widget _buildToolbar(double toolbarWidth, double iconSize, double spacing) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      width: toolbarWidth,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildToolbarButtons(iconSize, spacing),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildToolbarButtons(double iconSize, double spacing) {
    return [
      _buildToolbarButton(Icons.brush, "Pen", 'pen', iconSize, spacing),
      _buildToolbarButton(
          Icons.crop_square, "Shape", 'shape', iconSize, spacing),
      _buildToolbarButton(Icons.circle, "Stroke", 'stroke', iconSize, spacing),
      _buildToolbarButton(Icons.palette, "Color", 'color', iconSize, spacing),
      _buildToolbarButton(Icons.text_fields, "Text", 'text', iconSize, spacing),
      _buildToolbarButton(
          Icons.arrow_forward, "Arrow", 'arrow', iconSize, spacing),
      _buildToolbarButton(Icons.clear, "Clear", 'clear', iconSize, spacing),
    ];
  }

  Widget _buildToolbarButton(IconData icon, String label, String value,
      double iconSize, double spacing) {
    final bool isActive = _isToolActive(value);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: spacing),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor.withOpacity(0.2)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => value == 'clear' ? clearDrawing() : toggleBar(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: spacing / 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: iconSize * 0.4,
                  color: Theme.of(context).primaryColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToolActive(String value) {
    switch (value) {
      case 'pen':
        return isPenActive;
      case 'shape':
        return isShapeActive;
      case 'stroke':
        return isStrokeActive;
      case 'color':
        return isColorActive;
      default:
        return activeBar == value;
    }
  }

  Widget _buildToolOptions(String type, BoxConstraints constraints,
      double toolbarWidth, double bottomBarHeight, double spacing) {
    if (!['stroke', 'color', 'shape'].contains(type)) {
      return SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: toolbarWidth,
      right: 0,
      child: Container(
        height: bottomBarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildOptionsForType(type, spacing).map((widget) {
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

  List<Widget> _buildOptionsForType(String type, double spacing) {
    switch (type) {
      case 'stroke':
        return [2, 4, 6, 8]
            .map((width) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing),
                  child: StrokeButton(
                    label: width.toString(),
                    onTap: () => setStrokeWidth(width.toDouble()),
                  ),
                ))
            .toList();

      case 'color':
        return [
          Colors.black,
          Colors.red,
          Colors.blue,
          Colors.green,
        ]
            .map((color) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing),
                  child: ColorButton(
                    color: color,
                    onTap: () => setColor(color),
                  ),
                ))
            .toList();

      case 'shape':
        return [
          (Icons.crop_square, "Rectangle", ShapeType.rectangle),
          (Icons.circle, "Circle", ShapeType.circle),
          (Icons.linear_scale, "Line", ShapeType.line),
          (Icons.change_history, "Triangle", ShapeType.triangle),
        ]
            .map((shape) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing),
                  child: ShapeButton(
                    icon: shape.$1,
                    label: shape.$2,
                    onTap: () => selectShape(shape.$3),
                  ),
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
              _showTextDialog(details.localPosition);
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
              onTap: () => _showTextOptions(textData),
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
                      ? Colors.black.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  textData.text,
                  style: TextStyle(
                    color: textData.color,
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
    if (activeBar == 'pen' || activeBar == 'shape' || activeBar == 'arrow') {
      startDrawing(details.localPosition);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (activeBar == 'pen' || activeBar == 'shape' || activeBar == 'arrow') {
      updateDrawing(details.localPosition);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (activeBar == 'pen' || activeBar == 'shape' || activeBar == 'arrow') {
      stopDrawing();
    }
  }

  void _showTextDialog(Offset position) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return TextDialog(
          controller: controller,
          onAdd: () {
            if (controller.text.isNotEmpty) {
              addText(position, controller.text);
              Navigator.pop(context);
              setState(() {
                isTextDialogActive = false;
              });
            }
          },
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          isTextDialogActive = false;
        });
      }
    });
  }

  void _showTextOptions(TextData textData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TextOptionsDialog(
          textData: textData,
          onEdit: () {
            Navigator.pop(context);
            _showEditTextDialog(textData);
          },
          onDelete: () {
            setState(() {
              texts.remove(textData);
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEditTextDialog(TextData textData) {
    TextEditingController controller =
        TextEditingController(text: textData.text);
    showDialog(
      context: context,
      builder: (context) {
        return EditTextDialog(
          controller: controller,
          textData: textData,
          onUpdate: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                textData.text = controller.text;
              });
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
