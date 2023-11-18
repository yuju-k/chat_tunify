import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // freiends data
  final List<Map<String, String>> friends = [
    {
      'name': '이름',
      'email': 'example@example.com',
      'image':
          'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png'
    },
    {
      'name': '이름',
      'email': 'example@example.com',
      'image':
          'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png'
    },
    {
      'name': '이름',
      'email': 'example@example.com',
      'image':
          'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('연락처'),
          centerTitle: false,
          actions: [
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.person_add_alt)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.search),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '검색',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Text('내 프로필')),
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://cdn.pixabay.com/photo/2016/11/18/23/38/child-1837375_960_720.png'),
                ),
                title: const Text('이름'),
                subtitle: const Text('전화번호'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ),
              const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Text('친구')),
              Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(friends[index]['image'] ?? ''),
                      ),
                      title: Text(friends[index]['name'] ?? ''),
                      subtitle: Text(friends[index]['email'] ?? ''),
                      // trailing: IconButton(
                      //   icon: const Icon(Icons.message),
                      //   onPressed: () {},
                      // ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
