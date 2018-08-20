import 'package:draggable_list/src/orderable.dart';
import 'package:draggable_list/src/orderable_container.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

class OrderableStack<T> extends StatefulWidget {
  final List<T> items;
  final Direction direction;
  final Size itemSize;
  final double margin;
  final WidgetFactory<T> itemBuilder;
  final void Function(List<T>) onChange;

  OrderableStack({
    Key key,
    @required this.items,
    @required this.itemBuilder,
    @required this.itemSize,
    this.onChange,
    this.margin = 0.0,
    this.direction = Direction.Horizontal,
  }) : super(key: key);

  @override
  _OrderableStackState<T> createState() => _OrderableStackState<T>(items);
}

class _OrderableStackState<T> extends State<OrderableStack<T>> {
  List<Orderable<T>> _orderableItems;
  List<T> _lastOrder;

  _OrderableStackState(List<T> rawItems) {
    _orderableItems = enumerate(rawItems)
        .map((l) => Orderable<T>(value: l.value, dataIndex: l.index))
        .toList();
  }

  double get _step => widget.direction == Direction.Horizontal
      ? widget.itemSize.width + widget.margin
      : widget.itemSize.height + widget.margin;

  List<T> get _currentOrder =>
      _orderableItems.map((item) => item.value).toList();

  Offset getCurrentPosition(Orderable l) => l.selected
      ? l.currentPosition // if isDragged don't move
      : widget.direction == Direction.Horizontal
          ? new Offset(l.visibleIndex * (widget.itemSize.width + widget.margin),
              l.currentPosition.dy)
          : new Offset(l.currentPosition.dx,
              l.visibleIndex * (widget.itemSize.height + widget.margin));

  void updateItemsPos() {
    enumerate(_orderableItems).forEach((item) {
      item.value.visibleIndex = item.index;
      item.value.currentPosition = getCurrentPosition(item.value);
    });
  }

  void _onDragMove() {
    setState(() {
      sortOrderables<Orderable<T>, T>(
          items: _orderableItems,
          itemSize: widget.itemSize,
          margin: widget.margin,
          direction: widget.direction);
      updateItemsPos();
    });
  }

  void _onDrop() {
    setState(() {
      updateItemsPos();
      if (_currentOrder != _lastOrder) {
        _lastOrder = _currentOrder;
        if (widget.onChange != null) widget.onChange(_currentOrder);
      }
    });
  }

  List<OrderableWidget<T>> _updateZIndexes(
      List<OrderableWidget<T>> orderableItems) {
    final dragged = orderableItems.where((t) => t.data.selected);
    if (dragged.length > 0) {
      final item = dragged.first;
      orderableItems.remove(dragged.first);
      orderableItems.add(item);
    }
    return orderableItems;
  }

  List<OrderableWidget<T>> _buildOrderableWidgets() => _orderableItems
      .map((Orderable<T> l) => new OrderableWidget(
          key: new Key('item_${l.dataIndex}'),
          step: _step,
          itemBuilder: widget.itemBuilder,
          itemSize: widget.itemSize,
          direction: widget.direction,
          maxPos: _orderableItems.length * _step - widget.margin,
          data: l..currentPosition = getCurrentPosition(l),
          isDragged: l.selected,
          onDrop: _onDrop,
          onMove: _onDragMove))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: OrderableContainer<T>(
              direction: widget.direction,
              items: _updateZIndexes(_buildOrderableWidgets()),
              itemSize: widget.itemSize,
              margin: widget.margin),
        )
      ],
    );
  }
}
