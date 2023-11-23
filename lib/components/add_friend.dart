import 'package:flutter/material.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  String _friendName = '';

  void _addFriend() {
    // Add friend logic here
    print('Adding friend: $_friendName');

    // ContactsPage() Reloads
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text("친구 추가",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          // Add friend form
          TextField(
            onChanged: (value) {
              setState(() {
                _friendName = value;
              });
            },
            decoration: const InputDecoration(
              labelText: '아이디 입력',
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _addFriend,
            child: const Text('추가하기'),
          ),
        ],
      ),
    );
  }
}
