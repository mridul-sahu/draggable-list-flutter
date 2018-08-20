import 'package:draggable_list/src/orderable.dart';
import 'package:flutter/material.dart';

typedef Widget WidgetFactory<T>({Orderable<T> data, Size itemSize});

class OrderableContainer<T> extends StatefulWidget {
  final List<OrderableWidget<T>> items;

  final Size itemSize;
  final Direction direction;
  final double margin;

  OrderableContainer({
    @required this.items,
    @required this.itemSize,
    this.margin = 0.0,
    this.direction = Direction.Horizontal,
  });

  @override
  _OrderableContainerState createState() => _OrderableContainerState();
}

class _OrderableContainerState extends State<OrderableContainer> {
  get _stackSize => widget.direction == Direction.Horizontal
      ? Size(((widget.itemSize.width * widget.items.length) + (widget.margin * (widget.items.length - 1))),
          widget.itemSize.height)
      : Size(widget.itemSize.width,
      (widget.itemSize.height * widget.items.length) + (widget.margin * (widget.items.length - 1)));

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(_stackSize),
      child: Stack(
        children: widget.items,
      ),
    );
  }
}

class OrderableWidget<T> extends StatefulWidget {
  final Orderable<T> data;
  final Size itemSize;
  final double maxPos;
  final Direction direction;
  final VoidCallback onMove;
  final VoidCallback onDrop;
  final double step;
  final WidgetFactory<T> itemBuilder;

  OrderableWidget(
      {Key key,
      @required this.data,
      @required this.itemBuilder,
      @required this.maxPos,
      @required this.itemSize,
      this.onMove,
      this.onDrop,
      bool isDragged = false,
      this.direction = Direction.Horizontal,
      this.step = 0.0})
      : super(key: key);

  @override
  _OrderableWidgetState<T> createState() =>
      _OrderableWidgetState<T>(data: data);
}

class _OrderableWidgetState<T> extends State<OrderableWidget<T>> {
  Orderable<T> data;

  bool get _isHorizontal => widget.direction == Direction.Horizontal;

  _OrderableWidgetState({this.data});

  void _startDrag(DragStartDetails event) {
    setState(() {
      data.selected = true;
    });
  }

  void _endDrag(DragEndDetails event) {
    setState(() {
      data.selected = false;
      if (widget.onDrop != null) widget.onDrop();
    });
  }

  bool _moreThanMin(DragUpdateDetails event) =>
      (_isHorizontal ? data.x : data.y) + event.primaryDelta > 0;

  bool _lessThanMax(DragUpdateDetails event) =>
      (_isHorizontal
              ? (data.x + widget.itemSize.width)
              : (data.y + widget.itemSize.height)) +
          event.primaryDelta <
      widget.maxPos;

  Widget _buildGestureDetector({bool horizontal}) => horizontal
      ? GestureDetector(
          onHorizontalDragStart: _startDrag,
          onHorizontalDragEnd: _endDrag,
          onHorizontalDragUpdate: (event) {
            setState(() {
              if (_moreThanMin(event) && _lessThanMax(event))
                data.currentPosition =
                    Offset(data.x + event.primaryDelta, data.y);
              if (widget.onMove != null) widget.onMove();
            });
          },
          child: widget.itemBuilder(data: data, itemSize: widget.itemSize),
        )
      : GestureDetector(
          onVerticalDragStart: _startDrag,
          onVerticalDragEnd: _endDrag,
          onVerticalDragUpdate: (event) {
            setState(() {
              if (_moreThanMin(event) && _lessThanMax(event))
                data.currentPosition =
                    Offset(data.x, data.y + event.primaryDelta);
              if (widget.onMove != null) widget.onMove();
            });
          },
          child: widget.itemBuilder(data: data, itemSize: widget.itemSize),
        );

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: data.selected ? 1 : 300),
      left: data.x,
      top: data.y,
      child: _buildGestureDetector(horizontal: _isHorizontal),
    );
  }
}
