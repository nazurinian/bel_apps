import 'package:flutter/material.dart';

class SerialBTPage extends StatefulWidget {
  const SerialBTPage({super.key});

  @override
  State<SerialBTPage> createState() => _SerialBTPageState();
}

class _SerialBTPageState extends State<SerialBTPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Serial BT"),
      ),
      body: Container(),
    );
  }
}
