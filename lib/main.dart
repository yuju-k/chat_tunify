import 'package:chat_tunify/bloc/auth_bloc.dart';
import 'package:chat_tunify/bloc/message_receive_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:chat_tunify/home.dart';

import 'package:chat_tunify/auth/create.dart';
import 'package:chat_tunify/auth/create_profile.dart';
import 'package:chat_tunify/auth/forgot_password.dart';
import 'package:chat_tunify/auth/login.dart';

import 'package:chat_tunify/settings/edit_profile.dart';
import 'package:chat_tunify/settings/notification.dart';
import 'package:chat_tunify/settings/support.dart';
import 'package:chat_tunify/settings/terms_service.dart';

import 'package:chat_tunify/llm_api_service.dart';

import 'package:chat_tunify/bloc/contacts_bloc.dart';
import 'package:chat_tunify/bloc/profile_bloc.dart';
import 'package:chat_tunify/bloc/chat_bloc.dart';
import 'package:chat_tunify/bloc/message_send_bloc.dart';
import 'package:chat_tunify/bloc/chat_action_log_bloc.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
    // If it's a duplicate app error, ignore it as the app is already initialized.
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 로딩 중이거나 스트림이 연결되지 않은 경우 로딩 인디케이터를 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // 스트림이 연결되었고 데이터가 있을 때 화면을 설정
        Widget homeScreen = const CreatePage(); // 기본 홈 스크린을 로그인 페이지로 설정
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user != null) {
            homeScreen = const HomePage(); // 사용자가 로그인한 경우 홈 페이지로 설정
          }
        }
        final db.DatabaseReference databaseReference =
            db.FirebaseDatabase.instance.ref();
        final messageReceiveBloc =
            MessageReceiveBloc(databaseReference: databaseReference);
        final authBloc = AuthenticationBloc(FirebaseAuth.instance);

        // MaterialApp 반환
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ChatRoomBloc(), // Add ChatRoomBloc
            ),
            BlocProvider(
              create: (context) => MessageReceiveBloc(
                  databaseReference:
                      databaseReference), // Add ChatMessageReceiveBloc
            ),
            BlocProvider.value(
              value: messageReceiveBloc, // 기존의 MessageReceiveBloc을 사용
            ),
            BlocProvider<AuthenticationBloc>(create: (context) => authBloc),
            BlocProvider<MessageSendBloc>(
              create: (context) => MessageSendBloc(
                MessageGenerationService(),
                GoogleNLPService(),
                context.read<MessageReceiveBloc>(),
                authBloc,
                databaseReference: db.FirebaseDatabase.instance.ref(),
              ),
            ),
            BlocProvider(
              create: (context) => ContactsBloc(),
            ),
            BlocProvider(
              create: (context) => AuthenticationBloc(FirebaseAuth.instance),
            ),
            BlocProvider(
              create: (context) => ProfileBloc(),
            ),
            BlocProvider(
              create: (context) => ChatActionLogBloc(databaseReference),
            ),
          ],
          child: MaterialApp(
            title: 'MoodWave',
            theme: ThemeData(
              useMaterial3: true,

              // Define the default font family.
              textTheme: GoogleFonts.nanumGothicTextTheme(
                Theme.of(context).textTheme,
              ),

              // Define the default brightness and colors.
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFFA9ECA2),
                dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
                brightness: Brightness.light,
              ).copyWith(
                surface: Colors.lightGreen[50], // 배경색
                primary: Colors.black, // 기본 글자색
              ),
            ),
            home: homeScreen, // 조건에 따라 결정된 홈 스크린
            routes: {
              '/home': (context) => const HomePage(),
              '/login': (context) => const LoginPage(),
              '/create': (context) => const CreatePage(),
              '/create_profile': (context) => const CreateProfile(),
              '/forgot_password': (context) => const ForgotPasswordPage(),
              '/edit_profile': (context) => const EditProfile(),
              '/notification': (context) => const NotificationPage(),
              '/support': (context) => const SupportPage(),
              '/terms_service': (context) => const TermsServicePage(),
            },
          ),
        );
      },
    );
  }
}
