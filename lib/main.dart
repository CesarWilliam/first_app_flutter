import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
    // items.add(Item(title: "Item 3", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController(); // seta a variavel com a função de controlador de texto

  void add() {
    if(newTaskCtrl.text.isEmpty) {
      return;
    }
    setState(() {
      widget.items.add(
        Item(
          title: newTaskCtrl.text, 
          done: false,
        )
      );
      newTaskCtrl.text = "";
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance(); // aguarda até o SharedPreferences estiver completo
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField( // cria um campo de texto dinamico
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(
              color: Colors.white
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index){ // array que cria a lista, varrendo o array de item criado no HomePage()
          final item = widget.items[index];

          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),              
              value: item.done, // estado do checkbox, se é verdadeiro ou falso
              onChanged: (value){
                setState(() {
                  item.done = value;
                  save();
                }); 
              },
            ),
            key: Key(item.title), // id do item
            background: Container(
              color: Colors.red.withOpacity(0.5)
            ),
            onDismissed: (direction) {
              remove(index);
            },
          );

          // return CheckboxListTile(
          //   title: Text(item.title),
          //   key: Key(item.title), // id do item
          //   value: item.done, // estado do checkbox, se é verdadeiro ou falso
          //   onChanged: (value){
          //     setState(() {
          //       item.done = value;
          //     }); 
          //   },
          // );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add, // chamando a função add criada no click do botão
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}