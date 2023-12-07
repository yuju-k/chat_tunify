import 'package:flutter/material.dart';

class RecommandMessageList extends StatefulWidget {
  const RecommandMessageList({super.key});

  @override
  State<RecommandMessageList> createState() => _RecommandMessageListState();
}

class _RecommandMessageListState extends State<RecommandMessageList> {
  List<String> recommandMessages = [
    //추천메시지 불러오기
    '안녕하세요',
    '반갑습니다',
    '또 뵙네요',
  ];
  List<String> selectMessages = []; //선택한 메시지를 담을 리스트

  void addMessage(String message) {
    setState(() {
      selectMessages.clear();
      selectMessages.insert(0, message);
      // recommandMessages리스트에 있는 메시지를 selectMessages에 1번째 인덱스부터 하나씩 추가
      selectMessages.insertAll(1, recommandMessages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: selectMessages.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(selectMessages[index]),
        );
      },
    );
  }
}
