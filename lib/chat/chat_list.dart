import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_tunify/bloc/chat_bloc.dart';
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
          ),
          body: ListView.builder(
              padding: const EdgeInsets.all(5),
              itemExtent: 75.0,
              itemCount: state.chatRooms.length,
              itemBuilder: (BuildContext context, int index) {
                final chatRoom = state.chatRooms[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(chatRoom.imagePath),
                  ),
                  title: Text(chatRoom.title),
                  subtitle: Text(chatRoom.subtitle),
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
}
