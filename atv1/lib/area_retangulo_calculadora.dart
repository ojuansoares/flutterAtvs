import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AreaRetanguloCalculadoraWidget extends StatefulWidget {
  const AreaRetanguloCalculadoraWidget({super.key});

  @override
  State<AreaRetanguloCalculadoraWidget> createState() =>
      _AreaRetanguloCalculadoraWidgetState();
}

class _AreaRetanguloCalculadoraWidgetState extends State<AreaRetanguloCalculadoraWidget> {
  final TextEditingController _larguraController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  double? _area;

  final List<Map<String, dynamic>> _retangulos = [];

  void _calcularArea() {
    final larguraText = _larguraController.text.replaceAll(',', '.');
    final alturaText = _alturaController.text.replaceAll(',', '.');
    
    if (larguraText.trim().isEmpty) {
      _mostrarMensagem('Por favor, digite a largura do retângulo');
      return;
    }
    
    if (alturaText.trim().isEmpty) {
      _mostrarMensagem('Por favor, digite a altura do retângulo');
      return;
    }
    
    final largura = double.tryParse(larguraText);
    final altura = double.tryParse(alturaText);

    if (largura == null) {
      _mostrarMensagem('Largura inválida. Digite apenas números');
      return;
    }
    
    if (altura == null) {
      _mostrarMensagem('Altura inválida. Digite apenas números');
      return;
    }
    
    if (largura <= 0) {
      _mostrarMensagem('A largura deve ser maior que zero');
      return;
    }
    
    if (altura <= 0) {
      _mostrarMensagem('A altura deve ser maior que zero');
      return;
    }

    final area = largura * altura;

    setState(() {
      _area = area;

      _retangulos.add({
        'largura': largura,
        'altura': altura,
        'area': area,
        'timestamp': DateTime.now(),
      });
    });

    // Limpa os campos depois de adicionar
    _larguraController.clear();
    _alturaController.clear();
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _limparHistorico() {
    setState(() {
      _retangulos.clear();
    });
  }

  @override
  void dispose() {
    _larguraController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Área - Retângulo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Digite as dimensões do retângulo:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _larguraController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Largura',
                        hintText: 'Digite a largura (ex: 10,5)',
                        border: OutlineInputBorder(),
                        suffixText: 'unidades',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _alturaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Altura',
                        hintText: 'Digite a altura (ex: 8,2)',
                        border: OutlineInputBorder(),
                        suffixText: 'unidades',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _calcularArea,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calcular Área'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_area != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Área do Retângulo:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_area!.toStringAsFixed(2)} unidades²',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fórmula: Área = largura × altura',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_retangulos.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Histórico de Cálculos:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _limparHistorico,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Limpar'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Column(
                  children: _retangulos.map((retangulo) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.crop_square,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      title: Text(
                        'Área: ${retangulo['area'].toStringAsFixed(2)} unidades²',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Largura: ${retangulo['largura'].toStringAsFixed(2)} × Altura: ${retangulo['altura'].toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        '${retangulo['timestamp'].hour.toString().padLeft(2, '0')}:${retangulo['timestamp'].minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Informações:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('• Digite valores positivos para largura e altura'),
                    const Text('• Use vírgula ou ponto para números decimais'),
                    const Text('• Clique no botão "Calcular Área" para calcular'),
                    const Text('• Fórmula: Área = largura × altura'),
                    const Text('• Resultado em unidades quadradas (unidades²)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}