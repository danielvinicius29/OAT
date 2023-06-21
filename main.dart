import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de Universidades',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TelaInicial(),
        '/detalhes': (context) => TelaDetalhes(),
      },
    );
  }
}

class TelaInicial extends StatefulWidget {
  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<dynamic> universidades = [];
  List<dynamic> universidadesFiltradas = [];
  String filtroNome = '';

  Future<void> buscarUniversidades() async {
    var url = Uri.parse('http://universities.hipolabs.com/search');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        universidades = data;
        universidadesFiltradas = data;
      });
    } else {
      print('Erro ao buscar universidades: ${response.statusCode}');
    }
  }

  void filtrarPorPais(String pais) {
    setState(() {
      universidadesFiltradas = universidades
          .where((universidade) =>
          universidade['country'].toLowerCase().contains(pais.toLowerCase()))
          .toList();
    });
  }

  void filtrarPorNome(String nome) {
    setState(() {
      filtroNome = nome;
      universidadesFiltradas = universidades
          .where((universidade) =>
          universidade['name'].toLowerCase().contains(nome.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    buscarUniversidades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta de Universidades'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: filtrarPorNome,
              decoration: InputDecoration(
                labelText: 'Filtrar por nome',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: filtrarPorPais,
              decoration: InputDecoration(
                labelText: 'Filtrar por país',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: universidadesFiltradas.length,
              itemBuilder: (BuildContext context, int index) {
                var universidade = universidadesFiltradas[index];
                return ListTile(
                  title: Text(universidade['name']),
                  subtitle: Text(universidade['country']),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalhes',
                      arguments: universidade,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TelaDetalhes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universidade = ModalRoute.of(context)!.settings.arguments as dynamic;

    return Scaffold(
      appBar: AppBar(
        title: Text(universidade['name']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('País: ${universidade['country']}'),
            SizedBox(height: 10),
            Text('Domínio: ${universidade['domains'].join(", ")}'),
            SizedBox(height: 10),
            Text('Website: ${universidade['web_pages'].join(", ")}'),
          ],
        ),
      ),
    );
  }
}