import 'package:flutter/material.dart';
import 'message_list.dart';
import 'bottom_input_menu_box.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('박건우'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Stack(
          children: [
            //메시지 목록
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: MessageList(),
            ),
            //메시지 입력창 & 메뉴
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [BottomInputMenuBox()],
            ),
          ],
        ),
      ),
    );
  }
}
