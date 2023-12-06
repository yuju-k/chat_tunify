import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_tunify/bloc/contacts_bloc.dart';
import 'package:chat_tunify/bloc/chat_bloc.dart';
import 'package:chat_tunify/contacts/add_friend.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchTextcontroller = TextEditingController();
  bool _isSearchingFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isSearchingFocus = _focusNode.hasFocus;
      });
    });
    context.read<ContactsBloc>().add(LoadContacts());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchTextcontroller.dispose();
    super.dispose();
  }

  void _showAddFriendModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * .30,
        maxHeight: MediaQuery.of(context).size.height * .40,
      ),
      builder: (BuildContext bc) {
        return AddFriend();
      },
    );
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
                  onPressed: () => _showAddFriendModal(context),
                  icon: const Icon(Icons.person_add_alt),
                ),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildSearchBar(),
        ),
      ),
      body: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
          if (state is ContactsLoading) {
            //로딩 중
            return const Center(child: CircularProgressIndicator());
          } else if (state is ContactsLoaded) {
            //로딩 완료
            return _buildContactsView(state.contacts);
          } else if (state is ContactsSearchResults) {
            //검색 결과
            return _buildContactsView(state.searchResults);
          } else {
            return const Center(child: Text('오류가 발생했습니다.'));
          }
        },
      ),
    );
  }

  //검색창 위젯
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _searchTextcontroller,
              onChanged: (query) {
                if (query.isEmpty) {
                  // 검색창이 비어있으면 연락처 전체 목록을 보여줌
                  context.read<ContactsBloc>().add(LoadContacts());
                } else {
                  // 검색창에 검색어가 입력되면 검색어를 포함하는 사용자 보여주기
                  context.read<ContactsBloc>().add(SearchContacts(query));
                }
              },
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
                    start: 16, end: 20, top: 0, bottom: 0),
              ),
            ),
          ),

          // 취소 버튼을 누면 검색창이 사라지고 연락처 목록이 나타남
          _isSearchingFocus
              ? TextButton(
                  onPressed: () {
                    _focusNode.unfocus();
                    _searchTextcontroller.clear();
                    context.read<ContactsBloc>().add(LoadContacts());
                  },
                  child: const Text('취소'))
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  // 연락처 목록 위젯
  Widget _buildContactsView(List<Map<String, String>> contacts) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: CircleAvatar(
            // 프로필 사진
            backgroundImage: NetworkImage(contact['image'] ?? ''),
          ),
          title: Text(contact['userName'] ?? ''), // 이름
          //subtitle: Text(contact['phone'] ?? ''), // 전화번호
          onTap: () {
            // 연락처를 누르면 채팅방으로 이동
            final contactUserId = contact['user_id'];
            final chatBloc = context.read<ChatBloc>();
            final currentChatState = chatBloc.state;

            // 이미 채팅방이 생성된 상태인지 확인
            ChatRoom? existingChatRoom;
            if (currentChatState is ChatLoaded) {
              existingChatRoom = currentChatState.chatRooms.firstWhereOrNull(
                  (chatRoom) => chatRoom.userID == contactUserId);
            }
            // 채팅방이 생성된 상태라면 해당 채팅방으로 이동
            if (existingChatRoom != null) {
              // Navigate to existing chat room
              chatBloc.add(SelectChat(existingChatRoom));
              Navigator.pushNamed(context, '/chat');
            } else {
              //아니라면 새로운 채팅방을 생성한다.
              final newChatRoom = ChatRoom(
                userID: contactUserId ?? '',
                userName: contact['userName'] ?? '',
                lastMessage: '새로운 대화 시작', // or any initial message
                time: DateFormat('HH:mm').format(DateTime.now()),
                imagePath: contact['image'] ?? '',
              );
              chatBloc.add(SelectChat(newChatRoom));
              Navigator.pushNamed(context, '/chat');
            }
          },
        );
      },
    );
  }
}
