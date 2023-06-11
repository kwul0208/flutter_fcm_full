import 'package:flutter/material.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({ Key? key, required this.id }) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
      ),
      body: Column(
        children: [
          Text("${id}")
        ],
      ),
    );
  }
}