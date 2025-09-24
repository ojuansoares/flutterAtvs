import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MediaAritmeticaWidget extends StatefulWidget {
  const MediaAritmeticaWidget({super.key});

  @override
  State<MediaAritmeticaWidget> createState() => _MediaAritmeticaWidgetState();
}

class _MediaAritmeticaWidgetState extends State<MediaAritmeticaWidget> {
  final TextEditingController _nota1 = TextEditingController();
  final TextEditingController _nota2 = TextEditingController();
  final TextEditingController _nota3 = TextEditingController();

  double? _media;

  void _calcularMedia() {
    final nota1Value = _nota1.text.replaceAll(',', '.');
    final nota2Value = _nota2.text.replaceAll(',', '.');
    final nota3Value = _nota3.text.replaceAll(',', '.');
    final n1 = double.tryParse(nota1Value);
    final n2 = double.tryParse(nota2Value);
    final n3 = double.tryParse(nota3Value);

    if (n1 == null || n2 == null || n3 == null) {
      setState(() {
        _media = null;
      });
      return;
    }

    setState(() {
      _media = (n1 + n2 + n3) / 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nota1,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*,?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Nota 1',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nota2,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*,?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Nota 2',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nota3,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*,?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Nota 3',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _calcularMedia,
          child: const Text('Calcular Média'),
        ),
        const SizedBox(height: 8),
        if (_media != null)
          Text('Média Aritmética: ${_media!.toStringAsFixed(2)}'),
      ],
    );
  }
}
