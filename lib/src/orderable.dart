import 'dart:ui';

enum Direction { Vertical, Horizontal }

class Orderable<T> {
  final T value;
  final int dataIndex;
  int visibleIndex;
  Offset currentPosition = Offset.zero;
  bool selected = false;

  double get x => currentPosition.dx;

  double get y => currentPosition.dy;

  Orderable({this.value, this.dataIndex}) : visibleIndex = dataIndex;
}

void sortOrderables<T extends Orderable<U>, U>(
    {List<T> items,
    Size itemSize,
    double margin,
    Direction direction = Direction.Horizontal}) {

  int orderableHSort(T a, T b) {
    if (!a.selected && !b.selected)
      return a.visibleIndex.compareTo(b.visibleIndex);

    double xA = a.currentPosition.dx;
    double xB = b.currentPosition.dx;
    double halfW = itemSize.width / 2;
    double step = (halfW + margin);

    int result;

    if (a.selected) {
      if (a.visibleIndex > b.visibleIndex)
        result = (xA - step).compareTo(xB);
      else
        result = (xA + halfW).compareTo(xB);
    } else if (b.selected) {
      if (a.visibleIndex > b.visibleIndex)
        result = xA.compareTo(xB + halfW);
      else
        result = xA.compareTo((xB - step));
    }
    return result;
  }

  int orderableVSort(T a, T b) {
    if (!a.selected && !b.selected)
      return a.visibleIndex.compareTo(b.visibleIndex);

    double yA = a.currentPosition.dy;
    double yB = b.currentPosition.dy;
    double halfH = itemSize.height / 2;
    double step = (halfH + margin);

    int result;
    if (a.selected) {
      if (a.visibleIndex > b.visibleIndex)
        result = (yA - step).compareTo(yB);
      else
        result = (yA + halfH).compareTo(yB);
    } else if (b.selected) {
      if (a.visibleIndex > b.visibleIndex)
        result = yA.compareTo(yB + halfH);
      else
        result = yA.compareTo(yB - step);
    }
    return result;
  }

  items.sort(direction == Direction.Horizontal ? orderableHSort : orderableVSort);
}
