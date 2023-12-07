import 'package:flutter/material.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
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
}
