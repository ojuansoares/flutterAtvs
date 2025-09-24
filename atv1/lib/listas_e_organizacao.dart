import 'package:flutter/material.dart';

class ListasEOrganizacaoWidget extends StatefulWidget {
  const ListasEOrganizacaoWidget({super.key});

  @override
  State<ListasEOrganizacaoWidget> createState() =>
      _ListasEOrganizacaoWidgetState();
}

class _ListasEOrganizacaoWidgetState extends State<ListasEOrganizacaoWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas & Organização'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_cart), text: 'Lista de Compras'),
            Tab(icon: Icon(Icons.task_alt), text: 'Tarefas Diárias'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ListaDeComprasTab(),
          TarefasDiariasTab(),
        ],
      ),
    );
  }
}

// Tab 1: Lista de Compras
class ListaDeComprasTab extends StatefulWidget {
  const ListaDeComprasTab({super.key});

  @override
  State<ListaDeComprasTab> createState() => _ListaDeComprasTabState();
}

class _ListaDeComprasTabState extends State<ListaDeComprasTab> {
  final TextEditingController _itemController = TextEditingController();
  final List<Map<String, dynamic>> _itensCompra = [];

  void _adicionarItem() {
    if (_itemController.text.trim().isNotEmpty) {
      setState(() {
        _itensCompra.add({
          'nome': _itemController.text.trim(),
          'comprado': false,
          'timestamp': DateTime.now(),
        });
      });
      _itemController.clear();
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _itensCompra[index]['comprado'] = !_itensCompra[index]['comprado'];
    });
  }

  void _removerItem(int index) {
    setState(() {
      _itensCompra.removeAt(index);
    });
  }

  void _limparLista() {
    setState(() {
      _itensCompra.clear();
    });
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itensNaoComprados = _itensCompra.where((item) => !item['comprado']).length;
    final itensComprados = _itensCompra.where((item) => item['comprado']).length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Campo para adicionar item
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemController,
                          decoration: const InputDecoration(
                            labelText: 'Adicionar item',
                            hintText: 'Digite o nome do produto',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_basket),
                          ),
                          onSubmitted: (_) => _adicionarItem(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _adicionarItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  if (_itensCompra.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$itensNaoComprados',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text('Pendentes'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '$itensComprados',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('Comprados'),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _itensCompra.isNotEmpty ? _limparLista : null,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpar'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de itens
          Expanded(
            child: _itensCompra.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Sua lista está vazia',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Adicione itens para começar suas compras',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _itensCompra.length,
                    itemBuilder: (context, index) {
                      final item = _itensCompra[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: ListTile(
                          leading: Checkbox(
                            value: item['comprado'],
                            onChanged: (_) => _toggleItem(index),
                          ),
                          title: Text(
                            item['nome'],
                            style: TextStyle(
                              decoration: item['comprado']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item['comprado'] ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Text(
                            item['comprado'] ? 'Comprado' : 'Pendente',
                            style: TextStyle(
                              color: item['comprado'] ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerItem(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Tab 2: Tarefas Diárias
class TarefasDiariasTab extends StatefulWidget {
  const TarefasDiariasTab({super.key});

  @override
  State<TarefasDiariasTab> createState() => _TarefasDiariasTabState();
}

class _TarefasDiariasTabState extends State<TarefasDiariasTab> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final List<Map<String, dynamic>> _tarefas = [];
  
  Prioridade _prioridadeSelecionada = Prioridade.media;

  void _adicionarTarefa() {
    if (_nomeController.text.trim().isNotEmpty) {
      setState(() {
        _tarefas.add({
          'nome': _nomeController.text.trim(),
          'descricao': _descricaoController.text.trim(),
          'concluida': false,
          'prioridade': _prioridadeSelecionada,
          'timestamp': DateTime.now(),
        });
      });
      _nomeController.clear();
      _descricaoController.clear();
      _prioridadeSelecionada = Prioridade.media;
    }
  }

  void _toggleTarefa(int index) {
    setState(() {
      _tarefas[index]['concluida'] = !_tarefas[index]['concluida'];
    });
  }

  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
    });
  }

  void _limparTarefas() {
    setState(() {
      _tarefas.clear();
    });
  }

  Color _getCorPrioridade(Prioridade prioridade) {
    switch (prioridade) {
      case Prioridade.baixa:
        return Colors.green;
      case Prioridade.media:
        return Colors.orange;
      case Prioridade.alta:
        return Colors.red;
    }
  }

  String _getTextoPrioridade(Prioridade prioridade) {
    switch (prioridade) {
      case Prioridade.baixa:
        return 'Baixa';
      case Prioridade.media:
        return 'Média';
      case Prioridade.alta:
        return 'Alta';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tarefasPendentes = _tarefas.where((t) => !t['concluida']).length;
    final tarefasConcluidas = _tarefas.where((t) => t['concluida']).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Formulário para adicionar tarefa
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da tarefa',
                      hintText: 'Digite o nome da tarefa',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.task),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descricaoController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      hintText: 'Digite uma breve descrição',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Prioridade:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: Prioridade.values.map((prioridade) {
                      return Expanded(
                        child: Row(
                          children: [
                            Radio<Prioridade>(
                              value: prioridade,
                              groupValue: _prioridadeSelecionada,
                              onChanged: (value) {
                                setState(() {
                                  _prioridadeSelecionada = value!;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                _getTextoPrioridade(prioridade),
                                style: TextStyle(
                                  color: _getCorPrioridade(prioridade),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _adicionarTarefa,
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Tarefa'),
                        ),
                      ),
                      if (_tarefas.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _limparTarefas,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpar'),
                        ),
                      ],
                    ],
                  ),
                  if (_tarefas.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$tarefasPendentes',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text('Pendentes'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '$tarefasConcluidas',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('Concluídas'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de tarefas
          SizedBox(
            height: 400, // Altura fixa para a lista
            child: _tarefas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma tarefa cadastrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Adicione tarefas para organizar seu dia',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _tarefas.length,
                    itemBuilder: (context, index) {
                      final tarefa = _tarefas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: ListTile(
                          leading: Checkbox(
                            value: tarefa['concluida'],
                            onChanged: (_) => _toggleTarefa(index),
                          ),
                          title: Text(
                            tarefa['nome'],
                            style: TextStyle(
                              decoration: tarefa['concluida']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontWeight: FontWeight.bold,
                              color: tarefa['concluida'] ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tarefa['descricao'].isNotEmpty)
                                Text(
                                  tarefa['descricao'],
                                  style: TextStyle(
                                    color: tarefa['concluida'] ? Colors.grey : null,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getCorPrioridade(tarefa['prioridade']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getTextoPrioridade(tarefa['prioridade']),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tarefa['concluida'] ? 'Concluída' : 'Pendente',
                                    style: TextStyle(
                                      color: tarefa['concluida']
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerTarefa(index),
                          ),
                          isThreeLine: tarefa['descricao'].isNotEmpty,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

enum Prioridade { baixa, media, alta }