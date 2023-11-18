import 'package:flutter/material.dart';

import 'package:chat_tunify/auth/create.dart';
import 'package:chat_tunify/auth/create_profile.dart';
import 'package:chat_tunify/auth/forgot_password.dart';
import 'package:chat_tunify/auth/login.dart';

import 'package:chat_tunify/chat/chat.dart';
import 'package:chat_tunify/chat/chat_list.dart';

import 'package:chat_tunify/contacts/contacts.dart';

import 'package:chat_tunify/settings/edit_profile.dart';
import 'package:chat_tunify/settings/notification.dart';
import 'package:chat_tunify/settings/settings.dart';
import 'package:chat_tunify/settings/support.dart';
import 'package:chat_tunify/settings/terms_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ChatTunify',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'ChatTunify'),
        routes: {
          '/login': (context) => const LoginPage(),
          '/create': (context) => const CreatePage(),
          '/create_profile': (context) => const CreateProfile(),
          '/forgot_password': (context) => const ForgotPasswordPage(),
          '/chat': (context) => const ChatPage(),
          '/edit_profile': (context) => const EditProfile(),
          '/notification': (context) => const NotificationPage(),
          '/support': (context) => const SupportPage(),
          '/terms_service': (context) => const TermsServicePage(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    ContactsPage(),
    ChatListPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '연락처',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '대화',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
