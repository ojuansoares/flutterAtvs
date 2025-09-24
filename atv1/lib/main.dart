import 'package:flutter/material.dart';
import 'celcius_to_fahrenheit.dart';
import 'media_aritmetica.dart';
import 'desconto_calculadora.dart';
import 'area_retangulo_calculadora.dart';
import 'listas_e_organizacao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo Teste',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    Center(child: CelciusToFahrenheitWidget()),
    Center(child: MediaAritmeticaWidget()),
    Center(child: DescontoCalculadoraWidget()),
    Center(child: AreaRetanguloCalculadoraWidget()),
    Center(child: ListasEOrganizacaoWidget()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App com Múltiplas Sessões'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat),
            label: 'Celsius → Fahrenheit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Média Aritmética',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.discount),
            label: 'Desconto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.square_foot),
            label: 'Área Retângulo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Listas & Tarefas',
          ),
        ],
      ),
    );
  }
}
