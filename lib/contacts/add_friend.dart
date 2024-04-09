import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_tunify/bloc/contacts_bloc.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  String _friendName = '';

  void _addFriend() {
    if (_friendName.isNotEmpty) {
      // Trigger AddUser event
      BlocProvider.of<ContactsBloc>(context).add(AddUser(_friendName));

      // Close the modal after adding friend
      Navigator.of(context).pop();
    } else {
      // Show error if the input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              labelText: '친구 이메일 입력',
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
