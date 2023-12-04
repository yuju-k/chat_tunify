import 'package:flutter_bloc/flutter_bloc.dart';

// 대화방 정보를 나타내는 모델 클래스
class ChatRoom {
  final String userID; // 대화 상대방의 userID
  final String userName;
  final String lastMessage;
  final String time;
  final String imagePath;
  final List<Map<String, String>>? messages;

  const ChatRoom({
    required this.userID,
    required this.userName,
    required this.lastMessage,
    required this.time,
    required this.imagePath,
    this.messages,
  });
}

// **** BLoC 이벤트 **** //
abstract class ChatEvent {}

class LoadChats extends ChatEvent {}

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

//채팅방 선택 이벤트
class SelectChat extends ChatEvent {
  final ChatRoom selectedChatRoom;
  SelectChat(this.selectedChatRoom);
}

// **** BLoC 상태 **** //
abstract class ChatState {}

class ChatInitial extends ChatState {}

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
        imagePath: 'https://picsum.photos/200/200?random=7',
        messages: [
          ({'message': '안녕하세요', 'time': '10:00'}),
          ({'message': '메세지2', 'time': '10:01'}),
          ({'message': '메세지3', 'time': '10:02'}),
          ({'message': '메세지4', 'time': '10:03'}),
          ({'message': '메세지5', 'time': '10:04'}),
          ({'message': '메세지6', 'time': '10:05'}),
          ({'message': '메세지7', 'time': '10:06'}),
        ],
      ),
      const ChatRoom(
        userID: 'oppayam1005',
        userName: '박건우2',
        lastMessage: '채팅방 3의 마지막 대화 내용',
        time: '12:00',
        imagePath: 'https://picsum.photos/200/200?random=3',
      ),
    ];
    emit(ChatLoaded(chatRooms: chatRooms));
  }

  void _onSelectChat(SelectChat event, Emitter<ChatState> emit) {
    // 채팅방을 선택하는 로직
    // 데이터베이스에서 채팅방 정보를 불러온다(?)
    emit(ChatLoaded(
      chatRooms: (state as ChatLoaded).chatRooms,
      selectedChatRoom: event.selectedChatRoom,
    ));
  }
}
