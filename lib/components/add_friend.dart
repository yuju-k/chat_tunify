import 'package:flutter/material.dart';

class AddFriend extends StatefulWidget {
  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  String _friendName = '';

  void _addFriend() {
    // Add friend logic here
    print('Adding friend: $_friendName');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _friendName = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Friend Name',
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _addFriend,
            child: Text('Add Friend'),
          ),
        ],
      ),
    );
  }
}
