import 'package:chat_tunify/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_tunify/llm_api_service.dart';
import 'package:chat_tunify/bloc/message_receive_bloc.dart';

// Events
abstract class MessageSendEvent {}

class AzureSentimentAnalysisEvent extends MessageSendEvent {
  final String text;

  AzureSentimentAnalysisEvent(this.text);
}

class AzureSentimentAnalysisEvent2 extends MessageSendEvent {
  final String text;

  AzureSentimentAnalysisEvent2(this.text);
}

class ChatGptSendMessageEvent extends MessageSendEvent {
  final String message;

  ChatGptSendMessageEvent(this.message);
}

class FirebaseMessageSaveEvent extends MessageSendEvent {
  final String roomId;
  final String senderEmail;
  final String senderName;
  final String senderUID;
  final String firstMessageContent;
  final String originalMessageContent;
  final String convertMessageContent;
  final String timestamp;
  final bool isConvertMessage;
  final String originalSentiment;
  final String sendMessageSentiment;
  final int backspaceCount;
  final int refreshMessage;

  FirebaseMessageSaveEvent({
    required this.roomId,
    required this.senderEmail,
    required this.senderName,
    required this.senderUID,
    required this.firstMessageContent,
    required this.originalMessageContent,
    required this.convertMessageContent,
    required this.timestamp,
    required this.isConvertMessage,
    required this.originalSentiment,
    required this.sendMessageSentiment,
    required this.backspaceCount,
    required this.refreshMessage,
  });
}

class ChatGptRecommendMessageEvent extends MessageSendEvent {
  final String negativeMessage;
  final String roomId;

  ChatGptRecommendMessageEvent(this.negativeMessage, this.roomId);
}

// States
abstract class MessageSendState {}

class AzureSentimentAnalysisInitialState extends MessageSendState {}

class AzureSentimentAnalysisProcessingState extends MessageSendState {}

class AzureSentimentAnalysisSuccessState extends MessageSendState {
  final String analysisResult;

  AzureSentimentAnalysisSuccessState(this.analysisResult);
}

class AzureSentimentAnalysisSuccessState2 extends MessageSendState {
  final String analysisResult;

  AzureSentimentAnalysisSuccessState2(this.analysisResult);
}

class AzureSentimentAnalysisErrorState extends MessageSendState {
  final String error;

  AzureSentimentAnalysisErrorState(this.error);
}

class ChatGptSendMessageInitialState extends MessageSendState {}

class ChatGPTSendMessageSendingState extends MessageSendState {}

class ChatGPTSendMessageSentState extends MessageSendState {
  final String chatGptResponse;

  ChatGPTSendMessageSentState(this.chatGptResponse);
}

class ChatGPTSendMessageSendErrorState extends MessageSendState {
  final String error;

  ChatGPTSendMessageSendErrorState(this.error);
}

class FirebaseMessageSaveInitialState extends MessageSendState {}

class FirebaseMessageSaveSendingState extends MessageSendState {}

class FirebaseMessageSaveSentState extends MessageSendState {}

class FirebaseMessageSaveSendErrorState extends MessageSendState {
  final String error;

  FirebaseMessageSaveSendErrorState(this.error);
}

class ChatGptRecommendMessageState extends MessageSendState {
  final String chatGptRecommendResponse;

  ChatGptRecommendMessageState(this.chatGptRecommendResponse);
}

// BLoC
class MessageSendBloc extends Bloc<MessageSendEvent, MessageSendState> {
  final ChatGPTService chatGPTService;
  final AzureSentimentAnalysisService azureSentimentAnalysisService;
  final DatabaseReference databaseReference;
  final MessageReceiveBloc messageReceiveBloc;
  final AuthenticationBloc authBloc;

  MessageSendBloc(
    this.chatGPTService,
    this.azureSentimentAnalysisService,
    this.messageReceiveBloc,
    this.authBloc, {
    required this.databaseReference,
  }) : super(ChatGptSendMessageInitialState()) {
    on<AzureSentimentAnalysisEvent>(_onAzureSentimentAnalysisEvent);
    on<AzureSentimentAnalysisEvent2>(_onAzureSentimentAnalysisEvent2);
    on<FirebaseMessageSaveEvent>(_onFirebaseMessageSaveEvent);
    on<ChatGptRecommendMessageEvent>(_onChatGptRecommendMessageEvent);
  }

  Future<void> _onAzureSentimentAnalysisEvent(
    AzureSentimentAnalysisEvent event,
    Emitter<MessageSendState> emit,
  ) async {
    emit(AzureSentimentAnalysisProcessingState());
    try {
      final analysisResult =
          await azureSentimentAnalysisService.analyzeSentiment(event.text);
      emit(AzureSentimentAnalysisSuccessState(analysisResult));
    } catch (e) {
      emit(AzureSentimentAnalysisErrorState(e.toString()));
    }
  }

  Future<void> _onAzureSentimentAnalysisEvent2(
    AzureSentimentAnalysisEvent2 event,
    Emitter<MessageSendState> emit,
  ) async {
    emit(AzureSentimentAnalysisProcessingState());
    try {
      final analysisResult =
          await azureSentimentAnalysisService.analyzeSentiment(event.text);
      emit(AzureSentimentAnalysisSuccessState2(analysisResult));
    } catch (e) {
      emit(AzureSentimentAnalysisErrorState(e.toString()));
    }
  }

  Future<void> _onChatGptRecommendMessageEvent(
    ChatGptRecommendMessageEvent event,
    Emitter<MessageSendState> emit,
  ) async {
    emit(ChatGPTSendMessageSendingState());
    try {
      final currentState = authBloc.state;
      String currentUser;
      if (currentState is AuthenticationSuccess) {
        currentUser = currentState.user.displayName ?? 'Unknown';
      } else {
        currentUser = 'Unknown';
      }

      List<String> previousMessagesContent = messageReceiveBloc.previousMessages
          .map((message) => message.senderName == currentUser
              ? message.isConvertMessage
                  ? "나: ${message.convertMessageContent}"
                  : "나: ${message.originalMessageContent}"
              : message.isConvertMessage
                  ? "상대방: ${message.convertMessageContent}"
                  : "상대방: ${message.originalMessageContent}")
          .toList();

      if (previousMessagesContent.length > 20) {
        previousMessagesContent = previousMessagesContent
            .sublist(previousMessagesContent.length - 20);
      }

      final chatGptRecommandResponse =
          await chatGPTService.recommandMessageRequest(
        event.negativeMessage,
        previousMessagesContent,
      );

      DatabaseReference gptMessageRef = databaseReference
          .child('chat_rooms/${event.roomId}/gpt_messages')
          .push();
      await gptMessageRef.set({
        'originalMessageContent': event.negativeMessage,
        'messages': chatGptRecommandResponse,
        'timestamp': DateTime.now().toString(),
      });

      emit(ChatGptRecommendMessageState(chatGptRecommandResponse));
    } catch (e) {
      emit(ChatGPTSendMessageSendErrorState(e.toString()));
    }
  }

  Future<void> _onFirebaseMessageSaveEvent(
    FirebaseMessageSaveEvent event,
    Emitter<MessageSendState> emit,
  ) async {
    emit(FirebaseMessageSaveSendingState());
    try {
      DatabaseReference messageRef =
          databaseReference.child('messages/${event.roomId}').push();
      await messageRef.set({
        'senderUID': event.senderUID,
        'senderName': event.senderName,
        'senderEmail': event.senderEmail,
        'firstMessageContent': event.firstMessageContent,
        'originalMessageContent': event.originalMessageContent,
        'convertMessageContent': event.convertMessageContent,
        'isConvertMessage': event.isConvertMessage,
        'originalSentiment': event.originalSentiment,
        'sendMessageSentiment': event.sendMessageSentiment,
        'timestamp': event.timestamp,
        'backspaceCount': event.backspaceCount,
        'refreshMessage': event.refreshMessage,
      });

      DatabaseReference lastMessageRef =
          databaseReference.child('chat_rooms/${event.roomId}/last_message');
      await lastMessageRef.set(event.isConvertMessage
          ? event.convertMessageContent
          : event.originalMessageContent);

      DatabaseReference lastMessageTimestampRef = databaseReference
          .child('chat_rooms/${event.roomId}/last_message_timestamp');
      await lastMessageTimestampRef.set(event.timestamp);

      emit(FirebaseMessageSaveSentState());
    } catch (e) {
      emit(FirebaseMessageSaveSendErrorState(e.toString()));
    }
  }
}
