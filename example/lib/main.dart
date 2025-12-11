import 'package:flutter/material.dart';
import 'package:k_util/k_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'k_util Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('k_util Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Device Width: ${context.width}',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Is Phone? ${context.isPhone}',
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Today: ${DateTime.now().formatDate()}',
            )
          ],
        ),
      ),
    );
  }
}
