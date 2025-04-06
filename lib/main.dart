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
    print('Firebase initialized successfully');
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      print('Firebase initialization error: $e');
      rethrow;
    }
    print('Firebase already initialized (duplicate-app ignored)');
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        Widget homeScreen = const CreatePage();
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user != null) {
            homeScreen = const HomePage();
          }
        }

        final db.DatabaseReference databaseReference =
            db.FirebaseDatabase.instance.ref();
        final authBloc = AuthenticationBloc(FirebaseAuth.instance);
        final messageReceiveBloc =
            MessageReceiveBloc(databaseReference: databaseReference);

        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ChatRoomBloc()),
            BlocProvider(
                create: (context) =>
                    MessageReceiveBloc(databaseReference: databaseReference)),
            BlocProvider.value(value: messageReceiveBloc),
            BlocProvider.value(value: authBloc),
            BlocProvider<MessageSendBloc>(
              create: (context) => MessageSendBloc(
                messageGenerationService: MessageGenerationService(),
                googleNLPService: GoogleNLPService(),
                messageReceiveBloc: messageReceiveBloc,
                authBloc: authBloc,
                databaseReference: databaseReference,
              ),
            ),
            BlocProvider(create: (context) => ContactsBloc()),
            BlocProvider(create: (context) => ProfileBloc()),
            BlocProvider(
                create: (context) => ChatActionLogBloc(databaseReference)),
          ],
          child: MaterialApp(
            title: 'MoodWave',
            theme: ThemeData(
              useMaterial3: true,
              textTheme:
                  GoogleFonts.nanumGothicTextTheme(Theme.of(context).textTheme),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFA9ECA2),
                dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
                brightness: Brightness.light,
              ).copyWith(
                surface: Colors.lightGreen[50],
                primary: Colors.black,
              ),
            ),
            home: homeScreen,
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
