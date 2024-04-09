import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_tunify/bloc/auth_bloc.dart';
import 'package:chat_tunify/bloc/profile_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _imageUrl = '';
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<ProfileBloc>().add(ProfileLoadRequested(user.email!));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
          BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded) {
                setState(() {
                  _name = state.name;
                  _email = state.email;
                  _imageUrl = state.imageUrl;
                });
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded || state is ProfileInitial) {
                return _buildProfile();
              } else {
                return Container();
              }
            },
          ),
          const SizedBox(height: 15),
          // Other UI elements
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
            child: CircleAvatar(
              radius: 32,
              backgroundImage: _imageUrl.isNotEmpty
                  ? NetworkImage(_imageUrl)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider<Object>?,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _name,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _email,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

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
            BlocProvider.of<AuthenticationBloc>(context).add(
              LogoutRequested(),
            );
          },
        ),
      ],
    );
  } //_buildAppSetting
}
