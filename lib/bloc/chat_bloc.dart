import 'package:flutter_bloc/flutter_bloc.dart';

// 대화방 정보를 나타내는 모델 클래스
class ChatRoom {
  final String userID; // 대화 상대방의 userID
  final String userName;
  final String lastMessage;
  final String time;
  final String imagePath;

  const ChatRoom({
    required this.userID,
    required this.userName,
    required this.lastMessage,
    required this.time,
    required this.imagePath,
  });
}

// **** BLoC 이벤트 **** //
abstract class ChatEvent {
  // ...
}

class LoadChats extends ChatEvent {
  // ...
}

//채팅방 선택 이벤트
class SelectChat extends ChatEvent {
  final ChatRoom selectedChatRoom;
  SelectChat(this.selectedChatRoom);
}

//채팅방 생성
class CreateChat extends ChatEvent {
  final ChatRoom newChatRoom;
  CreateChat(this.newChatRoom);
}

//채팅방 삭제
class DeleteChat extends ChatEvent {
  final ChatRoom chatRoom;
  DeleteChat(this.chatRoom);
}

// **** BLoC 상태 **** //
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

// **** BLoC **** //
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<SelectChat>(_onSelectChat);
  }

  void _onLoadChats(LoadChats event, Emitter<ChatState> emit) {
    // 채팅방 목록을 불러오는 로직 // 더미데이터
    List<ChatRoom> chatRooms = [
      const ChatRoom(
        userID: 'oppayam1004',
        userName: '박건우',
        lastMessage: '채팅방 2의 마지막 대화 내용',
        time: '11:00',
        imagePath: 'assets/images/1.jpeg',
      ),
      const ChatRoom(
        userID: 'oppayam1005',
        userName: '박견우',
        lastMessage: '채팅방 3의 마지막 대화 내용',
        time: '12:00',
        imagePath: 'assets/images/1.jpeg',
      ),
    ];
    emit(ChatLoaded(chatRooms: chatRooms));
  }

  void _onSelectChat(SelectChat event, Emitter<ChatState> emit) {
    // 채팅방을 선택하는 로직
    emit(ChatLoaded(
      chatRooms: (state as ChatLoaded).chatRooms,
      selectedChatRoom: event.selectedChatRoom,
    ));
  }
}
