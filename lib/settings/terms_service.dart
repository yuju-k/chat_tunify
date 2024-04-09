import 'package:flutter/material.dart';

class TermsServicePage extends StatefulWidget {
  const TermsServicePage({super.key});

  @override
  State<TermsServicePage> createState() => _TermsServicePageState();
}

class _TermsServicePageState extends State<TermsServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Terms Service Page'),
      ),
    );
  }
}
