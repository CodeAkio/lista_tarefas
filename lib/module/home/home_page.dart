import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  var _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    var arquivo = File("${diretorio.path}/dados.json");

    return arquivo;
  }

  _salvarTarefa() {
    var textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    var dados = jsonEncode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      _salvarArquivo();
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = jsonDecode(dados);
      });
    });
  }

  Widget criarItemLista(context, index) {
    if (_listaTarefas.length > 0) {
      final item = _listaTarefas[index]["titulo"];

      return Dismissible(
          key: Key(item),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _ultimaTarefaRemovida = _listaTarefas[index];

            setState(() {
              _listaTarefas.removeAt(index);
            });

            _salvarArquivo();

            final snackbar = SnackBar(
              duration: Duration(seconds: 5),
              content: Text("Tarefa removida"),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _listaTarefas.insert(index, _ultimaTarefaRemovida);
                  });

                  _salvarArquivo();
                },
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          },
          background: Container(
            color: Colors.red,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                )
              ],
            ),
          ),
          child: CheckboxListTile(
            title: Text(_listaTarefas[index]['titulo']),
            value: _listaTarefas[index]['realizada'],
            onChanged: (valorAlterado) {
              setState(() {
                _listaTarefas[index]['realizada'] = valorAlterado;
              });
              _salvarArquivo();
            },
          ));
    } else {
      return ListTile(
        title: Text("Não há tarefas"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: Colors.purple,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.purple,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Adicionar Tarefa"),
                    content: TextField(
                      controller: _controllerTarefa,
                      decoration:
                          InputDecoration(labelText: "Digite sua tarefa"),
                      onChanged: (text) {
                        //
                      },
                    ),
                    actions: [
                      ElevatedButton(
                        child: Text("Cancelar"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        child: Text("Salvar"),
                        onPressed: () {
                          _salvarTarefa();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          },
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItemLista,
            ))
          ],
        ),
      ),
    );
  }
}
