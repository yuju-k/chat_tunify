import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '버전정보',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '1.0.0',
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
