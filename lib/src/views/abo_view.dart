import 'package:flutter/material.dart';

class AboView extends StatelessWidget {
  const AboView({super.key});
  static const String abo = '/abo';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AboView'),
      ),
      body: const Center(
        child: Text('Hello, Flutter!'),
      ),
    );
  }
}
