import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_tunify/bloc/chat_list_bloc.dart';
import 'package:chat_tunify/contacts/contacts.dart';
//import 'package:chat_tunify/chat/chat.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
      if (state is ChatLoaded) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('대화'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.add), //아이콘추가
                onPressed: () {
                  _openContactsPage();
                },
              ),
            ],
          ),
          body: ListView.builder(
              padding: const EdgeInsets.all(5),
              itemExtent: 75.0,
              itemCount: state.chatRooms.length,
              itemBuilder: (BuildContext context, int index) {
                final chatRoom = state.chatRooms[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chatRoom.imagePath),
                  ),
                  title: Text(chatRoom.userName),
                  subtitle: Text(chatRoom.lastMessage),
                  trailing: Text(chatRoom.time),
                  onTap: () {
                    context.read<ChatBloc>().add(SelectChat(chatRoom));
                    Navigator.pushNamed(context, '/chat');
                  },
                );
              }),
        );
      }
      return const Center(child: CircularProgressIndicator());
    });
  }

  void _openContactsPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Dialog(
          child: SizedBox(
            height: 500,
            child: ContactsPage(),
          ),
        );
      },
    );
  }
}
