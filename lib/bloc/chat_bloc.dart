import 'package:flutter_bloc/flutter_bloc.dart';

// 대화방 정보를 나타내는 모델 클래스
class ChatRoom {
  final String title;
  final String subtitle;
  final String time;
  final String imagePath;

  const ChatRoom({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.imagePath,
  });
}

// BLoC 이벤트
abstract class ChatEvent {
  // ...
}

class LoadChats extends ChatEvent {
  // ...
}

class SelectChat extends ChatEvent {
  final ChatRoom selectedChatRoom;
  SelectChat(this.selectedChatRoom);
}

// BLoC 상태
abstract class ChatState {
  // ...
}

class ChatInitial extends ChatState {
  // ...
}

class ChatLoaded extends ChatState {
  final List<ChatRoom> chatRooms;
  final ChatRoom? selectedChatRoom;

  ChatLoaded({required this.chatRooms, this.selectedChatRoom});
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    // LoadChats 이벤트
    on<LoadChats>((event, emit) {
      // 채팅방 목록을 불러오는 로직
      // 더미데이터
      List<ChatRoom> chatRooms = [
        const ChatRoom(
          title: '채팅방 제목1',
          subtitle: '채팅방 1의 마지막 대화 내용',
          time: '10:00',
          imagePath: 'assets/images/1.jpeg',
        ),
        const ChatRoom(
          title: '채팅방 제목2',
          subtitle: '채팅방 2의 마지막 대화 내용',
          time: '11:00',
          imagePath: 'assets/images/1.jpeg',
        ),
        const ChatRoom(
          title: '채팅방 제목3',
          subtitle: '채팅방 3의 마지막 대화 내용',
          time: '12:00',
          imagePath: 'assets/images/1.jpeg',
        ),
      ];
      emit(ChatLoaded(chatRooms: chatRooms));
    });

    // SelectChat 이벤트
    on<SelectChat>((event, emit) {
      emit(ChatLoaded(
        chatRooms: (state as ChatLoaded).chatRooms,
        selectedChatRoom: event.selectedChatRoom,
      ));
    });
  }
}
