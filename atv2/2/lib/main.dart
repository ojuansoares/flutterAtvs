import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras Offline',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ListaComprasScreen(),
    );
  }
}

class ListaComprasScreen extends StatefulWidget {
  @override
  _ListaComprasScreenState createState() => _ListaComprasScreenState();
}

class _ListaComprasScreenState extends State<ListaComprasScreen> {
  final TextEditingController _itemController = TextEditingController();
  List<Map<String, dynamic>> _itensCompra = [];
  bool _isLoading = true;
  String _caminhoArquivo = '';

  @override
  void initState() {
    super.initState();
    _carregarListaDoArquivo();
  }

  Future<void> _carregarListaDoArquivo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final listaJson = prefs.getString('lista_compras_json');
        
        setState(() {
          _caminhoArquivo = 'Browser LocalStorage (Web)';
        });
        
        print('Web - Dados carregados: $listaJson');
        
        if (listaJson != null && listaJson.isNotEmpty) {
          try {
            final List<dynamic> jsonData = json.decode(listaJson);
            
            setState(() {
              _itensCompra = jsonData.map((item) => {
                'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch,
                'nome': item['nome'],
                'comprado': item['comprado'],
                'timestamp': DateTime.parse(item['timestamp']),
              }).toList();
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Lista carregada! ${_itensCompra.length} itens encontrados'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e) {
            print('Erro ao decodificar JSON: $e');
            setState(() {
              _itensCompra = [];
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _itensCompra = [];
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🆕 Nova lista criada no LocalStorage'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final caminho = '${directory.path}/lista_compras.json';
        
        setState(() {
          _caminhoArquivo = caminho;
        });
        
        final arquivo = File(caminho);
        
        print('Mobile/Desktop - Verificando arquivo: $caminho');
        print('Arquivo existe: ${await arquivo.exists()}');
        
        if (await arquivo.exists()) {
          try {
            final conteudo = await arquivo.readAsString();
            print('Conteúdo do arquivo: $conteudo');
            
            if (conteudo.isNotEmpty) {
              final List<dynamic> jsonData = json.decode(conteudo);
              
              setState(() {
                _itensCompra = jsonData.map((item) => {
                  'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch,
                  'nome': item['nome'],
                  'comprado': item['comprado'],
                  'timestamp': DateTime.parse(item['timestamp']),
                }).toList();
                _isLoading = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Lista carregada do arquivo! ${_itensCompra.length} itens'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              setState(() {
                _itensCompra = [];
                _isLoading = false;
              });
            }
          } catch (e) {
            print('Erro ao ler arquivo: $e');
            setState(() {
              _itensCompra = [];
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _itensCompra = [];
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🆕 Arquivo será criado em: ${caminho.split('/').last}'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Erro geral ao carregar lista: $e');
      setState(() {
        _itensCompra = [];
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _salvarListaNoArquivo() async {
    try {
      final List<Map<String, dynamic>> jsonData = _itensCompra.map((item) => {
        'id': item['id'],
        'nome': item['nome'],
        'comprado': item['comprado'],
        'timestamp': item['timestamp'].toIso8601String(),
      }).toList();
      
      final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
      
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final sucesso = await prefs.setString('lista_compras_json', jsonString);
        
        print('Web - Dados salvos: $sucesso');
        print('Web - JSON salvo: $jsonString');
        
        if (sucesso) {
          print('✅ Lista salva no LocalStorage (Web)');
        } else {
          print('❌ Erro ao salvar no LocalStorage');
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final caminho = '${directory.path}/lista_compras.json';
        final arquivo = File(caminho);
        
        await arquivo.parent.create(recursive: true);
        await arquivo.writeAsString(jsonString);
        
        print('✅ Lista salva em: $caminho');
        print('JSON salvo: $jsonString');
        
        final verificacao = await arquivo.readAsString();
        print('Verificação - arquivo contém: $verificacao');
      }
    } catch (e) {
      print('❌ Erro ao salvar lista: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao salvar: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _adicionarItem() {
    if (_itemController.text.trim().isNotEmpty) {
      final novoItem = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'nome': _itemController.text.trim(),
        'comprado': false,
        'timestamp': DateTime.now(),
      };
      
      setState(() {
        _itensCompra.add(novoItem);
      });
      
      _itemController.clear();
      _salvarListaNoArquivo();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${novoItem['nome']} adicionado e salvo!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _itensCompra[index]['comprado'] = !_itensCompra[index]['comprado'];
    });
    _salvarListaNoArquivo();
    
    final item = _itensCompra[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['nome']} → ${item['comprado'] ? 'Comprado' : 'Pendente'}'),
        backgroundColor: item['comprado'] ? Colors.green : Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removerItem(int index) {
    final nomeItem = _itensCompra[index]['nome'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirmar Remoção'),
            ],
          ),
          content: Text('Deseja remover "$nomeItem" da lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _itensCompra.removeAt(index);
                });
                _salvarListaNoArquivo();
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ $nomeItem removido!'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Remover', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _limparLista() {
    if (_itensCompra.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirmar Limpeza'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deseja realmente limpar toda a lista?'),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ Esta ação removerá ${_itensCompra.length} itens',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _itensCompra.clear();
                });
                _salvarListaNoArquivo();
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🧹 Lista limpa e arquivo atualizado!'),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Limpar Tudo', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarInfoArquivo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Informações do JSON'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📍 Local de armazenamento:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _caminhoArquivo, 
                  style: TextStyle(
                    fontSize: 12, 
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text('📊 Estatísticas:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total de itens:'),
                  Text('${_itensCompra.length}', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Comprados:'),
                  Text('${_itensCompra.where((item) => item['comprado']).length}', 
                       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pendentes:'),
                  Text('${_itensCompra.where((item) => !item['comprado']).length}',
                       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kIsWeb ? Colors.blue.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      kIsWeb ? Icons.web : Icons.folder,
                      color: kIsWeb ? Colors.blue : Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kIsWeb 
                          ? 'Dados salvos no navegador (LocalStorage)'
                          : 'Dados salvos em arquivo JSON físico',
                        style: TextStyle(
                          fontSize: 12,
                          color: kIsWeb ? Colors.blue.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _visualizarJSON(),
              icon: Icon(Icons.code),
              label: Text('Ver JSON'),
            ),
            TextButton.icon(
              onPressed: () {
                _carregarListaDoArquivo();
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.refresh),
              label: Text('Recarregar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _visualizarJSON() {
    final jsonData = _itensCompra.map((item) => {
      'id': item['id'],
      'nome': item['nome'],
      'comprado': item['comprado'],
      'timestamp': item['timestamp'].toIso8601String(),
    }).toList();
    
    final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
    
    Navigator.of(context).pop();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.code, color: Colors.blue),
              SizedBox(width: 8),
              Text('Conteúdo JSON'),
              Spacer(),
              Chip(
                label: Text('${_itensCompra.length} itens'),
                backgroundColor: Colors.blue.shade100,
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  jsonString.isEmpty ? '[]' : jsonString,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📋 JSON exibido! ${kIsWeb ? '(LocalStorage)' : '(Arquivo)'}'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.check),
              label: Text('OK'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 24),
              Text(
                'Carregando lista do arquivo JSON...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                kIsWeb ? '🌐 Modo Web (LocalStorage)' : '📱 Modo App (Arquivo)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final itensNaoComprados = _itensCompra.where((item) => !item['comprado']).length;
    final itensComprados = _itensCompra.where((item) => item['comprado']).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 8),
            Text('Lista de Compras Offline'),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _carregarListaDoArquivo,
            tooltip: 'Recarregar do arquivo',
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _mostrarInfoArquivo,
            tooltip: 'Informações do arquivo',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 3,
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      kIsWeb ? Icons.web : Icons.description, 
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kIsWeb 
                              ? '🌐 Salvamento em LocalStorage (Web)' 
                              : '📁 Salvamento em Arquivo JSON',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            kIsWeb 
                              ? 'Browser LocalStorage (Persistente)' 
                              : 'lista_compras.json (Persistente)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.offline_pin, color: Colors.green),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            
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
                              labelText: 'Adicionar item à lista',
                              hintText: 'Ex: Leite, Pão, Ovos...',
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
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_itensCompra.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCountColumn('$itensNaoComprados', 'Pendentes', Colors.orange),
                          _buildCountColumn('$itensComprados', 'Comprados', Colors.green),
                          _buildCountColumn('${_itensCompra.length}', 'Total', Colors.blue),
                          Column(
                            children: [
                              IconButton(
                                onPressed: _limparLista,
                                icon: Icon(Icons.clear_all, size: 24),
                                tooltip: 'Limpar toda a lista',
                                color: Colors.red,
                              ),
                              Text(
                                'Limpar',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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

            Expanded(
              child: _itensCompra.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Sua lista está vazia',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Adicione itens para começar suas compras',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.offline_pin, color: Colors.green.shade700),
                                SizedBox(width: 8),
                                Text(
                                  '📱 Funciona offline com arquivo JSON!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
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
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          elevation: item['comprado'] ? 1 : 3,
                          child: ListTile(
                            leading: Checkbox(
                              value: item['comprado'],
                              onChanged: (_) => _toggleItem(index),
                              activeColor: Colors.green,
                            ),
                            title: Text(
                              item['nome'],
                              style: TextStyle(
                                decoration: item['comprado']
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item['comprado'] ? Colors.grey : null,
                                fontWeight: item['comprado'] ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item['comprado'] ? Colors.green : Colors.orange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item['comprado'] ? 'Comprado' : 'Pendente',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'ID: ${item['id']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerItem(index),
                              tooltip: 'Remover item',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountColumn(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}