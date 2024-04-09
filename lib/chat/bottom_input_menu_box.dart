import 'package:flutter/material.dart';
//import 'recommand_message.dart';

class BottomInputMenuBox extends StatefulWidget {
  final Function(String) onSend; // 메시지 전송 콜백
  const BottomInputMenuBox({super.key, required this.onSend});

  @override
  State<BottomInputMenuBox> createState() => _BottomInputMenuBoxState();
}

class _BottomInputMenuBoxState extends State<BottomInputMenuBox> {
  bool menuBoxVisible = false;
  bool recommandMessageBoxVisible = false;
  final TextEditingController _messageController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          menuBoxVisible = false;
          recommandMessageBoxVisible = false;
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      widget.onSend(_messageController.text); // 메시지 전송
      _messageController.clear(); // 입력 필드 초기화
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          //입력창와 메뉴, 이모티콘, 보내기 아이콘
          _inputMessage(),
          if (!menuBoxVisible &&
              !recommandMessageBoxVisible &&
              !_focusNode.hasFocus)
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Visibility(visible: menuBoxVisible, child: _menuBox()),
          Visibility(
              visible: recommandMessageBoxVisible,
              child: _recommandMessageBox()),
        ],
      ),
    );
  }

  Widget _inputMessage() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          //+ 아이콘 (메뉴박스: 사진, 카메라)
          IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  menuBoxVisible = !menuBoxVisible;
                  recommandMessageBoxVisible = false;
                });
              },
              icon: !menuBoxVisible
                  ? const Icon(Icons.add)
                  : const Icon(Icons.close)),
          //입력창
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '메세지를 입력하세요',
                contentPadding: EdgeInsets.only(left: 5),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          //이모지 버튼
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.emoji_emotions_outlined),
          ),
          //보내기 아이콘
          _focusNode.hasFocus
              ? IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _sendMessage();
                  },
                  icon: const Icon(Icons.send),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _menuBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      //높이를 화면의 30%
      height: MediaQuery.of(context).size.height * 0.28,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {},
            icon: const SizedBox(
              height: 60,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 35),
                    Text('사진/동영상'),
                  ]),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const SizedBox(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 35),
                  Text('카메라'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommandMessageBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      //높이를 화면의 30%
      height: MediaQuery.of(context).size.height * 0.28,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          //추천 메시지
          //const RecommandMessageList(),
          //닫기 버튼
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  menuBoxVisible = false;
                  recommandMessageBoxVisible = false;
                });
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
