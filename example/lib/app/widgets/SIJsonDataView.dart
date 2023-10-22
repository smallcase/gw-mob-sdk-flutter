import 'package:flutter/material.dart';

Map<Type, ({Color? color})> _meta = {
  int: (color: Colors.amber[900]),
  double: (color: Colors.purple),
  bool: (color: Colors.blue),
  String: (color: Colors.indigo),
  List: (color: Colors.deepOrange),
  Map: (color: Colors.green),
};
Widget _getValueWidget(Object value) {
  if (value is Map) {
    return SIMapView._internal(map: value);
  }
  if (value is List) {
    return SIListView._internal(list: value);
  }
  return Text(
    "$value",
    overflow: TextOverflow.ellipsis,
    style: TextStyle(color: _meta[value.runtimeType]?.color),
  );
}

class SIMapView extends StatefulWidget {
  final Map map;
  final bool _isRoot;
  const SIMapView._internal({super.key, required this.map}) : _isRoot = false;
  const SIMapView({super.key, required this.map}) : _isRoot = true;

  @override
  State<SIMapView> createState() => _SIMapViewState();
}

class _SIMapViewState extends State<SIMapView> {
  late bool isCollapsed;
  @override
  void initState() {
    isCollapsed = !widget._isRoot;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        isCollapsed = !isCollapsed;
      }),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: isCollapsed
            ? Text("${widget.map.entries}")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.map.entries
                    .map((e) =>
                        Flexible(flex: 0, child: SIMapFieldView(field: e)))
                    .toList(),
              ),
      ),
    );
  }
}

class SIListView extends StatefulWidget {
  final List list;
  final bool _isRoot;
  const SIListView._internal({super.key, required this.list}) : _isRoot = false;
  const SIListView({super.key, required this.list}) : _isRoot = true;

  @override
  State<SIListView> createState() => _SIListViewState();
}

class _SIListViewState extends State<SIListView> {
  late bool isCollapsed;
  @override
  void initState() {
    isCollapsed = !widget._isRoot;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        isCollapsed = !isCollapsed;
      }),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: isCollapsed
            ? Text("${widget.list}")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.list
                    .map((e) => Flexible(flex: 0, child: _getValueWidget(e)))
                    .toList(),
              ),
      ),
    );
  }
}

class SIMapFieldView extends StatelessWidget {
  final MapEntry field;
  const SIMapFieldView({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${field.key}: ${field.value.runtimeType}"),
          ],
        ),
        SizedBox.square(dimension: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getValueWidget(field.value),
          ],
        ),
      ],
    );
  }
}
