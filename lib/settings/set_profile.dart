import 'package:flutter/material.dart';

class SetProfileComponent extends StatefulWidget {
  const SetProfileComponent({super.key});

  @override
  State<SetProfileComponent> createState() => _SetProfileComponentState();
}

class _SetProfileComponentState extends State<SetProfileComponent> {
  @override
  Widget build(BuildContext context) {
    return const Form(
      child: Column(
        children: [
          Text('Set Profile Page'),
        ],
      ),
    );
  }
}
