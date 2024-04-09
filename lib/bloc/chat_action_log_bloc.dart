import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';

// Enum to represent the different chat actions
enum ChatAction {
  send,
  arrowUpward,
  recommandMessageCard,
  refresh,
  viewOriginalMessage,
  viewOriginalMessageClose,
  recommendMessageCardClose, // 추천 메시지 창 닫기 액션 추가
}

// Event to log the chat action
class ChatActionLogEvent {
  final ChatAction action;
  final String roomId; // Adding roomId to the event
  final String userName; // 사용자 ID 추가
  ChatActionLogEvent(this.action, this.roomId, this.userName);
}

// State after logging the action (can be extended for more complex scenarios)
class ChatActionLogState {
  final String message;
  ChatActionLogState(this.message);
}

// BLoC for chat action logging
class ChatActionLogBloc extends Bloc<ChatActionLogEvent, ChatActionLogState> {
  final DatabaseReference _databaseReference;

  ChatActionLogBloc(this._databaseReference)
      : super(ChatActionLogState('Initial State')) {
    on<ChatActionLogEvent>((event, emit) {
      _logChatAction(event.action, event.roomId, event.userName);
      emit(ChatActionLogState('Logged ${event.action.toString()}'));
    });
  }

  void _logChatAction(ChatAction action, String roomId, String userName) {
    final actionString = action.toString().split('.').last; // Enum 값을 문자열로 변환
    final actionPath = 'chat_rooms/$roomId/log_data/$userName/$actionString';
    final ref = _databaseReference.child(actionPath);

    ref.get().then((DataSnapshot snapshot) {
      if (snapshot.exists) {
        int currentCount = int.parse(snapshot.value.toString());
        ref.set(currentCount + 1);
      } else {
        ref.set(1);
      }
    });
  }
}
