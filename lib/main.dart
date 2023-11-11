import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const String request = "api.hgbrasil.com";
const String key = "68296e11";

Future<void> main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  var client = http.Client();

  http.Response response =
      await client.get(Uri.https(request, 'finance', {'key': key}));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar = 0;
  double real = 0;
  double euro = 0;

  TextEditingController realController = TextEditingController();
  TextEditingController dolarController = TextEditingController();
  TextEditingController euroController = TextEditingController();

  void realChanged(String text) {
    if (text == 0 || text.isEmpty) {
      resetData();
      return;
    }
    double real = double.parse(text);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  dolarChanged(String text) {
    if (text == 0 || text.isEmpty) {
      resetData();
      return;
    }
    double dolar = double.parse(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  euroChanged(String text) {
    if (text == 0 || text.isEmpty) {
      resetData();
      return;
    }
    double euro = double.parse(text);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void resetData() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "\$ Conversor \$",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        actions: [
          TextButton(onPressed: resetData, child: const Icon(Icons.refresh)),
        ],
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                  child: Text(
                "Carregando dados!",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 25,
                ),
              ));
            case ConnectionState.active:
            default:
              if (snapshot.hasError) {
                return const Center(
                    child: Text(
                  "Erro ao sincronizar",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                ));
              } else {
                dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        buildTextField(
                            "Reais", "R\$ ", realController, realChanged),
                        const SizedBox(
                          height: 25,
                        ),
                        buildTextField(
                            "Dólares", "US\$ ", dolarController, dolarChanged),
                        const SizedBox(
                          height: 25,
                        ),
                        buildTextField(
                            "Euro", "EUR\$ ", euroController, euroChanged),
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function chng) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefix: Text(prefix),
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: (value) {
      chng(value);
    },
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
