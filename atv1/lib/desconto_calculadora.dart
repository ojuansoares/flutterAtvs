import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DescontoCalculadoraWidget extends StatefulWidget {
  const DescontoCalculadoraWidget({super.key});

  @override
  State<DescontoCalculadoraWidget> createState() =>
      _DescontoCalculadoraWidgetState();
}

class _DescontoCalculadoraWidgetState extends State<DescontoCalculadoraWidget> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _descontoController = TextEditingController();

  double? _precoFinal;

  final List<Map<String, dynamic>> _produtos = [];

  void _calcularDesconto() {
    final nome = _nomeController.text;
    final precoText = _precoController.text.replaceAll(',', '.');
    final descontoText = _descontoController.text.replaceAll(',', '.');
    
    final preco = double.tryParse(precoText);
    final desconto = double.tryParse(descontoText);

    if (preco == null || desconto == null) {
      setState(() {
        _precoFinal = null;
      });
      return;
    }

    final precoFinal = preco * (1 - desconto / 100);

    setState(() {
      _precoFinal = precoFinal;

      _produtos.add({
        'nome': nome,
        'precoOriginal': preco,
        'desconto': desconto,
        'precoFinal': precoFinal,
      });
    });

    // Limpa os campos depois de adicionar
    _nomeController.clear();
    _precoController.clear();
    _descontoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nomeController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Nome do produto',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _precoController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*,?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Preço original',
            border: OutlineInputBorder(),
            hintText: 'Ex: 100,50',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descontoController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*,?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Porcentagem de desconto (%)',
            border: OutlineInputBorder(),
            hintText: 'Ex: 15,5',
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _calcularDesconto,
          child: const Text('Calcular e Adicionar Produto'),
        ),
        const SizedBox(height: 8),
        if (_precoFinal != null)
          Text('Preço final com desconto: R\$ ${_precoFinal!.toStringAsFixed(2)}'),
        const SizedBox(height: 16),
        const Text(
          'Produtos adicionados:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _produtos.length,
          itemBuilder: (context, index) {
            final produto = _produtos[index];
            return ListTile(
              title: Text(
                  'Nome: ${produto['nome']} \nPreço Original: R\$ ${produto['precoOriginal'].toStringAsFixed(2)}'),
              subtitle: Text(
                  'Desconto: ${produto['desconto']}%  →  Preço Final: R\$ ${produto['precoFinal'].toStringAsFixed(2)}'),
            );
          },
        )
      ],
    );
  }
}
