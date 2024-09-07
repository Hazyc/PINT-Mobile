import 'package:flutter/material.dart';


class CountField extends StatefulWidget {
  final String campoId;
  final String label;
  final String initialValue;
  final ValueChanged<int> onChanged;

  CountField({
    required this.campoId,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _CountFieldState createState() => _CountFieldState();
}

class _CountFieldState extends State<CountField> {
  late int currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = int.tryParse(widget.initialValue) ?? 0;
  }

  void _decrement() {
    setState(() {
      if (currentValue > 0) {
        currentValue--;
        widget.onChanged(currentValue);
        print('Contagem ${widget.campoId} decremented to $currentValue');
      }
    });
  }

  void _increment() {
    setState(() {
      currentValue++;
      widget.onChanged(currentValue);
      print('Contagem ${widget.campoId} incremented to $currentValue');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: _decrement,
            ),
            Text(currentValue.toString()),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _increment,
            ),
          ],
        ),
      ],
    );
  }
}