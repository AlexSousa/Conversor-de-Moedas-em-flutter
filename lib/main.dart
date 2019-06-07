import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:async/async.dart';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=597bd88a";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController realController = TextEditingController();
  TextEditingController dolarController = TextEditingController();
  TextEditingController euroController = TextEditingController();

  void realChange(String text) {
    if (text.isEmpty) {
      reset();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void dolarChange(String text) {
    if (text.isEmpty) {
      reset();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void euroChange(String text) {
    if (text.isEmpty) {
      reset();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void reset() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  double dolar;
  double euro;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor"),
        centerTitle: true,
        backgroundColor: Colors.amber,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: reset,
          )
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregamentos Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error ao Carregar Dados",
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTextField(
                            "Reais", "R\$", realController, realChange),
                        Divider(),
                        buildTextField(
                            "Dolares", "US\$", dolarController, dolarChange),
                        Divider(),
                        buildTextField(
                            "Euros", "£", euroController, euroChange),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController entrada, Function f) {
  return TextField(
    controller: entrada,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
