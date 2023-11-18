import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchTextcontroller = TextEditingController();
  bool _isSearchingFocus = false;

  // freiends data
  final List<Map<String, String>> friends = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isSearchingFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('연락처'),
          centerTitle: false,
          actions: !_isSearchingFocus
              ? [
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.person_add_alt)),
                ]
              : null,
          bottom: // Search Bar
              PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _searchTextcontroller,
                      decoration: InputDecoration(
                          hintText: '검색',
                          filled: true,
                          fillColor: Colors.blueGrey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsetsDirectional.only(
                              start: 16, end: 20, top: 0, bottom: 0)),
                    ),
                  ),
                  _isSearchingFocus
                      ? //textbutton
                      TextButton(
                          onPressed: () {
                            _focusNode.unfocus();
                            _searchTextcontroller.clear();
                          },
                          child: const Text('취소'))
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: friends.isEmpty
                      ? 2
                      : friends.length +
                          1, //친구 목록이 비어있으면 아이템 카운트 2, 아니면 친구 목록 + 1
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
                            child: Text(
                              '내 프로필',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png'),
                            ),
                            title: const Text('내 이름'),
                            subtitle: const Text('나의 이메일'),
                            trailing:
                                // Icons.edit 아이콘을 누르면 /edit_profile 페이지로 이동
                                IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(context, '/edit_profile');
                              },
                            ),
                          ),
                          const Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
                            child: Text(
                              '친구',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (friends.isEmpty) {
                      //친구 목록이 비어있을 때
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text('등록된 친구가 없습니다.'),
                        ),
                      );
                    } else {
                      //친구 목록
                      final int friendIndex =
                          index - 1; // "내 프로필" 섹션을 제외한 인덱스 조정
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(friends[friendIndex]['image'] ?? ''),
                        ),
                        title: Text(friends[friendIndex]['name'] ?? ''),
                        subtitle: Text(friends[friendIndex]['email'] ?? ''),
                        // trailing: IconButton(
                        //   icon: Icon(Icons.message),
                        //   onPressed: () {},
                        // ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
