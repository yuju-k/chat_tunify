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
  final List<Map<String, String>> friends = [
    //image, name, email
    {
      'image':
          'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png',
      'name': '박건우',
      'phone': '010-5373-1391',
    },
    {
      'image':
          'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png',
      'name': 'Sanghyun',
      'phone': '010-5373-1391',
    },
    {
      'image':
          'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png',
      'name': 'Jooyoung',
      'phone': '010-5373-1391',
    },
    {
      'image':
          'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png',
      'name': 'SangGi',
      'phone': '010-5373-1391',
    },
    {
      'image':
          'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png',
      'name': 'Sujin',
      'phone': '010-5373-1391',
    },
  ];

  // 검색된 친구들을 저장할 리스트
  List<Map<String, String>> _searchedFriends = [];

  void _searchFriends(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchedFriends = []; // 검색 필드가 비어있으면 검색 결과 리스트를 비움
      });
      return; // 메서드 종료
    }

    final searchedFriends = friends.where((friend) {
      final nameLower = friend['name']!.toLowerCase();
      final queryLower = query.toLowerCase();

      return nameLower.contains(queryLower);
    }).toList();

    setState(() {
      _searchedFriends = searchedFriends;
    });
  }

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
            padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _searchTextcontroller,
                    onChanged: (query) => _searchFriends(query),
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
                          _searchedFriends.clear();
                        },
                        child: const Text('취소'))
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
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
                              title: const Text('강유주'),
                              //subtitle: const Text('나의 고민'),
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
                        return _buildFriendsListView(friendIndex);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // _isSearchingFocus가 true일 때 Container를 표시
          // Container는 검은색 배경을 가지고, 투명도를 조절하여 검은색 배경을 표시
          _isSearchingFocus
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                )
              : const SizedBox.shrink(),

          // _isSearchingFocus가 true일 때 검색 결과를 표시
          _isSearchingFocus
              ? _buildSearchResultsListView()
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  // 친구 목록을 표시하는 위젯
  Widget _buildFriendsListView(int friendIndex) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: 0, end: 0, top: 5, bottom: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage(friends[friendIndex]['image'] ?? ''),
            ),
            title: Text(friends[friendIndex]['name'] ?? ''),
            //subtitle: Text(friends[friendIndex]['email'] ?? ''),
            // trailing: IconButton(
            //   icon: Icon(Icons.message),
            //   onPressed: () {},
            // ),
            onTap: () {
              Navigator.pushNamed(context, '/chat');
            },
          ),
        ),
        const Divider(
          color: Colors.transparent,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }

  // 검색 결과를 표시하는 위젯
  Widget _buildSearchResultsListView() {
    if (_searchedFriends.isEmpty) {
      return const SizedBox.shrink(); // 검색 결과가 없으면 아무것도 표시하지 않음
    } else {
      return Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: _searchedFriends.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 0, end: 0, top: 5, bottom: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(_searchedFriends[index]['image']!),
                    ),
                    title: Text(_searchedFriends[index]['name']!),
                    onTap: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                  ),
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 1,
                  thickness: 1,
                ),
              ],
            );
          },
        ),
      );
    }
  }
}
