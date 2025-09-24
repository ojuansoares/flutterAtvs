import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CelciusToFahrenheitWidget extends StatefulWidget {
  const CelciusToFahrenheitWidget({super.key});

  @override
  State<CelciusToFahrenheitWidget> createState() =>
      _CelciusToFahrenheitWidgetState();
}

class _CelciusToFahrenheitWidgetState extends State<CelciusToFahrenheitWidget> {
  final TextEditingController _controller = TextEditingController();
  double? _fahrenheit;

  void _convert() {
    final valorText = _controller.text.replaceAll(',', '.');
    final celsius = double.tryParse(valorText);
    if (celsius == null) {
      setState(() {
        _fahrenheit = null;
      });
      return;
    }
    setState(() {
      _fahrenheit = (celsius * 9 / 5) + 32;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*,?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Temperatura em Celsius',
            border: OutlineInputBorder(),
            hintText: 'Ex: 40',
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _convert,
          child: const Text('Converter'),
        ),
        const SizedBox(height: 8),
        if (_fahrenheit != null)
          Text('Temperatura em Fahrenheit: ${_fahrenheit!.toStringAsFixed(2)}'),
      ],
    );
  }
}
