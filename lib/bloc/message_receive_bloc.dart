// message_receive_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_tunify/chat/message_class.dart';

// Events
abstract class MessageReceiveEvent {}

class ListenForMessages extends MessageReceiveEvent {
  final String roomId;
  ListenForMessages({required this.roomId});
}

class UpdateMessages extends MessageReceiveEvent {
  final List<Message> messages;
  UpdateMessages(this.messages);
}

// States
abstract class MessageReceiveState {}

class MessageReceiveInitial extends MessageReceiveState {}

class MessagesUpdated extends MessageReceiveState {
  final List<Message> messages;
  MessagesUpdated(this.messages);
}

// BLoC
class MessageReceiveBloc
    extends Bloc<MessageReceiveEvent, MessageReceiveState> {
  final DatabaseReference databaseReference;
  StreamSubscription? _messagesSubscription;

  MessageReceiveBloc({required this.databaseReference})
      : super(MessageReceiveInitial()) {
    on<ListenForMessages>(_onListenForMessages);
    on<UpdateMessages>((event, emit) {
      emit(MessagesUpdated(event.messages));
    });
  }

  List<Message> get previousMessages {
    if (state is MessagesUpdated) {
      return (state as MessagesUpdated).messages;
    } else {
      return [];
    }
  }

  Future<void> _onListenForMessages(
      ListenForMessages event, Emitter<MessageReceiveState> emit) async {
    _messagesSubscription?.cancel();
    _messagesSubscription = databaseReference
        .child('messages')
        .child(event.roomId)
        .onValue
        .listen((event) {
      final messages = <Message>[];
      final messagesSnapshot = event.snapshot;
      if (messagesSnapshot.value != null) {
        final messagesMap =
            Map<String, dynamic>.from(messagesSnapshot.value as Map);
        messagesMap.forEach((messageId, messageData) {
          final message =
              Message.fromMap(Map<String, dynamic>.from(messageData ?? {}));
          messages.add(message);
        });
      }
      // Sort messages by timestamp in ascending order
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      add(UpdateMessages(messages));
    });
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
