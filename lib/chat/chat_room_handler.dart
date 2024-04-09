import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_tunify/bloc/chat_bloc.dart';
import 'package:chat_tunify/chat/chat.dart';

class ChatRoomHandler {
  static Future<void> handleChatRoom(
      BuildContext context, Map<String, dynamic> contact) async {
    final String friendEmail = contact['email'];

    final chatRoomBloc = BlocProvider.of<ChatRoomBloc>(context);
    chatRoomBloc.add(CheckChatRoomExist(friendEmail));

    await for (ChatRoomState state in chatRoomBloc.stream) {
      if (state is ChatRoomExist) {
        //print('ChatRoomExist');
        //ChatRoomPage로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              name: contact['name'],
              email: contact['email'],
              uid: contact['uid'],
              roomId: state.roomId,
            ),
          ),
        );
        break;
      } else if (state is ChatRoomNotExist) {
        //친구랑 채팅방이 없는 경우
        chatRoomBloc.add(CreateChatRoom(friendEmail));
      } else if (state is ChatRoomCreated) {
        //print('ChatRoomCreated Success');
        //채팅방 생성 성공
        // ChatRoomPage로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              name: contact['name'],
              email: contact['email'],
              uid: contact['uid'],
              roomId: state.roomId,
            ),
          ),
        );
        break;
      }
    }
  }
}
