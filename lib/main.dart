import 'package:chat_tunify/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:chat_tunify/home.dart';

import 'package:chat_tunify/auth/create.dart';
import 'package:chat_tunify/auth/create_profile.dart';
import 'package:chat_tunify/auth/forgot_password.dart';
import 'package:chat_tunify/auth/login.dart';

import 'package:chat_tunify/chat/chat.dart';

import 'package:chat_tunify/settings/edit_profile.dart';
import 'package:chat_tunify/settings/notification.dart';
import 'package:chat_tunify/settings/support.dart';
import 'package:chat_tunify/settings/terms_service.dart';

import 'package:chat_tunify/bloc/chat_list_bloc.dart';
import 'package:chat_tunify/bloc/contacts_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Flutter엔진이 준비 된 상태에서 실행
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ChatBloc()..add(LoadChats()),
        ),
        BlocProvider(
          create: (context) => ContactsBloc()..add(LoadContacts()),
        ),
        BlocProvider(
          create: (context) => AuthenticationBloc(FirebaseAuth.instance),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
          '/main': (context) => const MyHomePage(title: 'ChatTunify'),
          '/home': (context) => const HomePage(),
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: ((context, state) {
      if (state is AuthenticationInitial) {
        // FirebaseAuth의 currentUser를 사용하여 로그인 상태 확인
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // 이미 로그인한 사용자
          return const HomePage();
        }
        // 로그인하지 않은 사용자
        return const CreatePage();
      } else if (state is AuthenticationLoading) {
        //로딩중일 때
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is AuthenticationSuccess) {
        return const HomePage();
      } else {
        // AuthenticationFailure 상태 또는 기타 상태
        return const Scaffold(
            body: Center(
          child: Text('Something went wrong'),
        ));
      }
    }));

    /* Bloc 사용하지 않을 때 코드 */
    // return StreamBuilder<User?>(
    //     stream: FirebaseAuth.instance.authStateChanges(),
    //     builder: (context, snapshot) {
    //       //오류처리
    //       if (snapshot.hasError) {
    //         return const Scaffold(
    //           body: Center(
    //             child: Text('Something went wrong'),
    //           ),
    //         );
    //       }

    //       //로딩 상태
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Scaffold(
    //           body: Center(
    //             child: CircularProgressIndicator(),
    //           ),
    //         );
    //       }

    //       //로그인하지 않은 사용자의 경우 CreatePage 반환
    //       if (!snapshot.hasData || snapshot.data == null) {
    //         return CreatePage();
    //       }

    //       //로그인 되어 있는 경우
    //       return Scaffold(
    //         // appBar: AppBar(
    //         //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //         //   title: Text(widget.title),
    //         // ),
    //         body: Center(
    //           child: _widgetOptions.elementAt(_selectedIndex),
    //         ),
    //         bottomNavigationBar: BottomNavigationBar(
    //           items: const <BottomNavigationBarItem>[
    //             BottomNavigationBarItem(
    //               icon: Icon(Icons.contacts),
    //               label: '연락처',
    //             ),
    //             BottomNavigationBarItem(
    //               icon: Icon(Icons.chat),
    //               label: '대화',
    //             ),
    //             BottomNavigationBarItem(
    //               icon: Icon(Icons.settings),
    //               label: '설정',
    //             ),
    //           ],
    //           currentIndex: _selectedIndex,
    //           onTap: _onItemTapped,
    //         ),
    //       );
    //     });
  }
}
