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

  bool isMenuBoxVisual = false; // 플러스버튼 누르면 메뉴박스보이고, 다시 누르면 메뉴박스 안보이게하기 위한 변수

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
                _focusNode.unfocus(); // 텍스트필드 포커스 해제

                setState(() {
                  isMenuBoxVisual = false; // 메뉴창 닫기
                });
              },
              child: Container(
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _messageList(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _bottomMenu(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Center(child: Text('채팅방을 선택해주세요'));
      },
    );
  }

  Widget _bottomMenu() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _inputMessage(),
          isMenuBoxVisual ? _menuBox() : const SizedBox(),
          _focusNode.hasFocus
              ? const SizedBox()
              : SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        ],
      ),
    );
  }

  Widget _messageList() {
    // 더미데이터
    List<Map<String, dynamic>> dummyData = [
      {
        'imagePath': 'https://picsum.photos/250?image=9',
        'userName': '박건우',
        'messages': '안녕하세요.',
        'originalMessages': '',
        'time': '오후 3:00',
        'isMe': false,
        'isTransMessage': false,
      },
      {
        'imagePath': 'https://picsum.photos/250?image=9',
        'userName': '박건우',
        'messages': '천재',
        'originalMessages': '바보',
        'time': '오후 3:00',
        'isMe': false,
        'isTransMessage': true,
      },
      {
        'imagePath': 'https://picsum.photos/250?image=9',
        'userName': '박건우',
        'messages': '천재! @@@@@@@@@@@ 줄바꿈@@@##!!@@@ 줄바꿈 줄바꿈 줄바꿈 줄바꿈 줄바꿈 줄바꿈',
        'originalMessages': '바보! 줄바꿈 줄바꿈 줄바꿈 줄바꿈 줄바꿈 줄바꿈 줄바꿈 줄바꿈',
        'time': '오후 3:00',
        'isMe': false,
        'isTransMessage': true,
      },
      {
        'imagePath': 'https://picsum.photos/250?image=10',
        'userName': '강유주',
        'messages': '헉 12341234123413413413413413414134',
        'originalMessages': '',
        'time': '오후 3:00',
        'isMe': true,
        'isTransMessage': false,
      },
    ];

    return ListView.builder(
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        return _buildMessageList(
          dummyData[index]['imagePath'],
          dummyData[index]['userName'],
          dummyData[index]['messages'],
          dummyData[index]['originalMessages'],
          dummyData[index]['time'],
          dummyData[index]['isMe'],
          dummyData[index]['isTransMessage'],
        );
      },
    );
  }

  Widget _buildMessageList(String imagePath, String userName, String messages,
      String originalMessages, String time, bool isMe, bool isTransMessage) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      color: !isMe ? Colors.indigo[50] : Colors.grey[50],
      child: Column(
        children: [
          // 프로필 사진과 메시지, 시간을 나타내는 Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(imagePath),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: const TextStyle(fontSize: 15)),
                        isTransMessage ? _transMessageYes() : const SizedBox(),
                        const Spacer(),
                        isTransMessage
                            ? _originalMessageButton(originalMessages, messages)
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _viewMessage(
                            messages, originalMessages, isTransMessage),
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 5),
                          child: Text(
                            time,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transMessageYes() {
    //변환된메시지 맞으면 이름 옆에 아이콘 표시하는 위젯
    return const Row(
      children: [
        SizedBox(width: 5),
        Icon(Icons.published_with_changes_sharp,
            size: 12, color: Colors.indigoAccent),
        SizedBox(width: 1),
        Text(
          "변환된 메시지",
          style: TextStyle(color: Colors.indigoAccent, fontSize: 12),
        ),
      ],
    );
  }

  //메시지 보여주기
  Widget _viewMessage(
      String messages, String originalMessages, bool isTransMessage) {
    //** */
    //**SnackBar로 원본 메시지 보여주기//** */
    // void showSnackbar(BuildContext context) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       behavior: SnackBarBehavior.floating,
    //       margin: const EdgeInsets.only(bottom: 80, left: 10, right: 10),
    //       content: RichText(
    //           text: TextSpan(
    //         text: '[원본메시지]\n',
    //         style: const TextStyle(
    //           fontSize: 14,
    //           fontWeight: FontWeight.bold,
    //         ),
    //         children: <TextSpan>[
    //           TextSpan(
    //               text: originalMessages,
    //               style: const TextStyle(
    //                 fontSize: 14,
    //               ))
    //         ],
    //       )),
    //       duration: const Duration(seconds: 3),
    //       action: SnackBarAction(
    //         label: '닫기',
    //         onPressed: () {},
    //       )));
    // }
    //** */

    return Expanded(
      child: Text(
        messages,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );

    //** 메시지 색상 변경 및 아이콘 표시해서 보여주는 버전 */
    // return Expanded(
    //   child: isTransMessage
    //       ? InkWell(
    //           onTap: () {
    //             _focusNode.unfocus(); // 텍스트필드 포커스 해제
    //             showSnackbar(context);
    //           },
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               Text(
    //                 messages,
    //                 style: const TextStyle(
    //                   fontSize: 15,
    //                   color: Colors.indigo,
    //                   //점선밑줄
    //                   //decoration: TextDecoration.underline,
    //                   decorationStyle: TextDecorationStyle.dotted,
    //                   decorationColor: Colors.indigo,
    //                 ),
    //               ),
    //               const SizedBox(width: 5),
    //               const Icon(
    //                 Icons.published_with_changes_sharp,
    //                 size: 15,
    //                 color: Colors.indigoAccent,
    //               ),
    //             ],
    //           ))
    //       : Text(
    //           messages,
    //           style: const TextStyle(
    //             fontSize: 15,
    //             color: Colors.black,
    //           ),
    //         ),
    // );
  }

  Widget _originalMessageButton(String originalMessages, String transMessages) {
    void showAlert(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.visibility, size: 15, color: Colors.deepPurple),
                SizedBox(width: 5),
                Text("원본 보기",
                    style: TextStyle(fontSize: 15, color: Colors.deepPurple)),
              ],
            ),
            content: //받은 메시지(transMessage)와 원본메시지 표시
                Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: originalMessages,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        )),
                  ]),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('닫기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return InkWell(
        onTap: () {
          _focusNode.unfocus(); // 텍스트필드 포커스 해제
          showAlert(context);
        },
        child: const Row(
          children: [
            Text("원본 보기",
                style: TextStyle(fontSize: 12, color: Colors.deepPurple)),
            SizedBox(width: 3),
            Icon(Icons.visibility, size: 15, color: Colors.deepPurple),
          ],
        ));
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
                      _focusNode.requestFocus(); //포커스를 준다.
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : IconButton(
                  onPressed: () {
                    if (_focusNode.hasFocus) {
                      _focusNode.unfocus(); // 포커스 해제
                      setState(() {
                        isMenuBoxVisual = true; // 메뉴창을 연다
                      });
                    } else {
                      setState(() {
                        isMenuBoxVisual = true; // 메뉴창을 연다
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
                  //이모지 버튼
                  IconButton(
                    onPressed: () {
                      //show emoji keyboard
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined),
                  ),
                  //보내기 버튼
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
        ],
      ),
    );
  }
}
