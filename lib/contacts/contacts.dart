import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_tunify/bloc/contacts_bloc.dart'; // ContactsBloc을 임포트
import 'package:chat_tunify/components/add_friend.dart';

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
            return const Center(child: CircularProgressIndicator());
          } else if (state is ContactsLoaded) {
            return _buildContactsView(state.contacts);
          } else if (state is ContactsSearchResults) {
            return _buildContactsView(state.searchResults);
          } else {
            return const Center(child: Text('오류가 발생했습니다.'));
          }
        },
      ),
    );
  }

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
                  context.read<ContactsBloc>().add(LoadContacts());
                } else {
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

  Widget _buildContactsView(List<Map<String, String>> contacts) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(contact['image'] ?? ''),
          ),
          title: Text(contact['name'] ?? ''),
          subtitle: Text(contact['phone'] ?? ''),
          onTap: () {
            // 연락처 탭 이벤트 처리
          },
        );
      },
    );
  }
}
