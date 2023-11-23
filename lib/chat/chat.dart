import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_tunify/bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return
        //  BlocProvider(
        //     create: (context) => ChatBloc()..add(LoadChats()),
        //     child:
        BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoaded && state.selectedChatRoom != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.selectedChatRoom!.title),
            ),
            body: Center(
              child: Text('채팅방: ${state.selectedChatRoom!.title}'),
            ),
          );
        }
        return const Center(child: Text('채팅방을 선택해주세요'));
      },
    );
  }
}
