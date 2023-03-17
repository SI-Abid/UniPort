import 'package:flutter/material.dart';
import 'package:uniport/version_1/services/helper.dart';
import 'package:uniport/version_1/widgets/widgets.dart';

Future<void> main(List<String> args) async {
  await initiate();
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const TestHome(),
    );
  }
}

class TestHome extends StatelessWidget {
  const TestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: const Center(child: StudentInfoBody()),
    );
  }
}
