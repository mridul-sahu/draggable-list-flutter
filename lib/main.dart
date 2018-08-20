import 'package:draggable_list/src/orderable.dart';
import 'package:draggable_list/src/orderable_stack.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Draggable List Demo',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(body: DraggableList()));
  }
}

class DraggableList extends StatelessWidget {
  Widget _itemBuilder({Orderable<String> data, Size itemSize}) {
    return Container(
      key: Key("orderableDataWidget${data.dataIndex}"),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: data != null && !data.selected
            ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.cyan
            : Colors.orange,
      ),
      width: itemSize.width,
      height: itemSize.height,
      child: Center(
          child: Column(children: [
        Text(
          "${data.value}",
          style: TextStyle(fontSize: 36.0, color: Colors.white),
        )
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrderableStack<String>(
      direction: Direction.Horizontal,
      items: ["A", "B", "C", "D"],
      itemSize: const Size(50.0, 50.0),
      margin: 10.0,
      itemBuilder: _itemBuilder,
    );
  }
}
