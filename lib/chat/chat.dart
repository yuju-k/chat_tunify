import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_tunify/bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FocusNode _focusNode = FocusNode();

  bool onlyTransVerifyMode = false; //변환메시지확인 가능모드 활성화?
  bool originalVerifyMode = true; //오리지날메시지모드 활성화?

  bool isMenuBoxVisual = false; //플러스버튼 터치여부

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // TextField가 포커스를 받으면 isMenuBoxVisual를 false로 설정
        setState(() {
          isMenuBoxVisual = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // FocusNode 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoaded && state.selectedChatRoom != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.selectedChatRoom!.userName), //유저이름
            ),
            body: GestureDetector(
              onTap: () {
                // 텍스트필드 포커스 해제
                _focusNode.unfocus();

                // 메뉴창 닫기
                setState(() {
                  isMenuBoxVisual = false;
                });
              },
              child: Center(
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildMessageList(
                                "https://picsum.photos/200/200?random=4",
                                "박건우",
                                "낚시갈꺼야!",
                                "03:00",
                                false,
                                false),
                            _buildMessageList(
                                "https://picsum.photos/200/200?random=3",
                                "나",
                                "않대!",
                                "03:00",
                                true,
                                false),
                            _buildMessageList(
                                "https://picsum.photos/200/200?random=4",
                                "박건우",
                                "왜 않돼!",
                                "03:02",
                                false,
                                true),
                          ],
                        ),
                      ),
                      _inputMessage(),
                      isMenuBoxVisual ? _menuBox() : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(child: Text('채팅방을 선택해주세요'));
      },
    );
  }

  Widget _buildMessageList(String imagePath, String userName, String messages,
      String time, bool isMe, bool isTransMessage) {
    // 상대방이 보낸 메시지 (isMe가 false일 때)
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      color: !isMe ? Colors.grey[100] : Colors.white,
      child: Column(
        children: [
          // 프로필 사진과 메시지, 시간을 나타내는 Row
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundImage: NetworkImage(imagePath),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 3),
                    Text(
                      messages,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          isTransMessage //변환된메시지인가? 변환된메시지이면, '원본메시지 확인' 버튼을 보여준다.
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // onlyTransVerifyMode //변환메시지확인 가능모드 활성화?
                    //     ? const Icon(
                    //         Icons.trip_origin,
                    //         size: 12,
                    //         color: Colors.indigo,
                    //       )
                    //     : const SizedBox(),
                    originalVerifyMode //오리지날메시지모드 활성화?
                        ? ElevatedButton(
                            onPressed: () {},
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Colors.indigo,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '원본메시지 확인',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  // 메시지 입력창
  Widget _inputMessage() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Row(
        children: [
          isMenuBoxVisual
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      isMenuBoxVisual = false; //메뉴창을 닫는다.
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _focusNode.requestFocus(); //포커스를 준다.
                      });
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : IconButton(
                  onPressed: () {
                    if (_focusNode.hasFocus) {
                      // 포커스 해제
                      _focusNode.unfocus();

                      // 포커스 해제 후 약간의 지연을 추가
                      Future.delayed(const Duration(milliseconds: 100), () {
                        setState(() {
                          // 메뉴창을 연다
                          isMenuBoxVisual = true;
                        });
                      });
                    } else {
                      setState(() {
                        // 메뉴창을 연다
                        isMenuBoxVisual = true;
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                //아이템간 간격 10
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '메세지를 입력하세요',
                        contentPadding: EdgeInsets.only(left: 5),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  //이모지
                  IconButton(
                    onPressed: () {
                      //show emoji keyboard
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
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
          IconButton(
            onPressed: () {},
            icon: const SizedBox(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, size: 35),
                  Text('음성메시지'),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const SizedBox(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 35),
                  Text('위치'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
