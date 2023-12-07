import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 사진 & 사용자 이름 & 계정이메일 표시
          _buildProfile(),

          const SizedBox(height: 15),

          // 프로필 설정
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text('계정 관리'),
          ),
          _buildProfileSetting(),

          const SizedBox(height: 15),

          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text('앱 설정'),
          ),
          // 앱 설정
          _buildAppSetting(),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              border: Border.all(
                color: Colors.lightBlue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage('https://picsum.photos/200'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '박건우',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'oppayam1004@gmail.com',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ], //프로필사진
      ),
    );
  } //_buildProfile

  Widget _buildProfileSetting() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('프로필관리'),
          onTap: () {
            Navigator.pushNamed(context, '/edit_profile');
          },
        ),
      ],
    );
  } //_buildProfileSetting

  Widget _buildAppSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('알림 설정'),
          onTap: () {
            Navigator.pushNamed(context, '/notification');
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('개인정보 처리방침'),
          onTap: () {
            Navigator.pushNamed(context, '/terms_service');
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('앱 정보'),
          onTap: () {
            Navigator.pushNamed(context, '/support');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('로그아웃'),
          onTap: () {
            //TODO: 로그아웃 기능 구현
          },
        ),
      ],
    );
  } //_buildAppSetting
}
