import 'package:chat_tunify/chat/chat_room_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_tunify/bloc/contacts_bloc.dart';
import 'package:chat_tunify/contacts/add_friend.dart';
import 'package:rxdart/rxdart.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchTextcontroller = TextEditingController();
  final _searchSubject = PublishSubject<String>();
  bool _isSearchingFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    context.read<ContactsBloc>().add(LoadContacts());

    // rxdart; 검색 쿼리 디바운싱(Debouncing) 추가
    _searchSubject.debounceTime(const Duration(milliseconds: 300)).listen((query)=>_searchContacts(query));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchTextcontroller.dispose();
    _searchSubject.close();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isSearchingFocus = _focusNode.hasFocus;
    });
  }

  void _showAddFriendModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * .50,
        maxHeight: MediaQuery.of(context).size.height * .60,
      ),
      builder: (BuildContext bc) {
        return const AddFriend();
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
      body: BlocConsumer<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is AddUserSuccess) {
            _showSuccessSnackBar('Friend added: ${state.userEmail}');
            context.read<ContactsBloc>().add(LoadContacts());
          } else if (state is AddUserFailure) {
            _showErrorSnackBar('Failed to add friend: ${state.error}');
            _reloadContacts();
          }
        },
        builder: (context, state) {
          if (state is ContactsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ContactsLoaded) {
            return _buildContactsView(state.contacts);
          } else if (state is ContactsSearchResults) {
            return _buildContactsView(state.searchResults);
          } else if (state is ContactsFailure) {
            return _buildErrorView(state.error);
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const[
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('연락처를 불러오는 중입니다...'),
              ],
            ),
          );

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
              onChanged: (value) => _searchSubject.add(value),
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
          _isSearchingFocus ? _buildCancelButton() : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: _cancelSearch,
      child: const Text('취소'),
    );
  }

  Widget _buildContactsView(List<Map<String, dynamic>> contacts) {
    if (contacts.isEmpty) {
      return const Center(
        child: Text(
          '친구가 존재하지 않습니다.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: _buildProfileImage(contact['imageUrl']),
          title: Text(contact['name'] ?? ''),
          subtitle: Text(contact['statusMessage'] ?? ''),
          onTap: () => _navigateToChatRoom(contact),
        );
      },
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    return CircleAvatar(
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? NetworkImage(imageUrl) as ImageProvider<Object>?
          : const AssetImage('assets/images/default_profile.png'),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(child: Text('오류가 발생했습니다: $error'));
  }

  void _searchContacts(String query) {
    if (query.isEmpty) {
      context.read<ContactsBloc>().add(LoadContacts());
    } else {
      context.read<ContactsBloc>().add(SearchContacts(query));
    }
  }

  void _cancelSearch() {
    _focusNode.unfocus();
    _searchTextcontroller.clear();
    context.read<ContactsBloc>().add(LoadContacts());
  }

  void _navigateToChatRoom(Map<String, dynamic> contact) {
    ChatRoomHandler.handleChatRoom(context, contact);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _reloadContacts() {
    if (context.read<ContactsBloc>().state is! ContactsLoading) {
      context.read<ContactsBloc>().add(LoadContacts());
    }
  }
}
