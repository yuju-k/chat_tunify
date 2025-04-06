import 'package:chat_tunify/bloc/auth_bloc.dart';
import 'package:chat_tunify/bloc/message_receive_bloc.dart';
import 'package:chat_tunify/llm_api_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 이벤트 정의: 메시지 전송과 관련된 다양한 작업을 나타냄
abstract class MessageSendEvent {
  const MessageSendEvent();
}

// 감정 분석 요청 이벤트: 사용자가 입력한 텍스트의 감정을 분석
class AzureSentimentAnalysisEvent extends MessageSendEvent {
  final String text; // 분석할 텍스트

  const AzureSentimentAnalysisEvent(this.text);
}

// 메시지 저장 이벤트: 채팅 메시지를 Firebase에 저장
class FirebaseMessageSaveEvent extends MessageSendEvent {
  final String roomId; // 채팅방 ID
  final String senderEmail; // 발신자 이메일
  final String senderName; // 발신자 이름
  final String senderUID; // 발신자 UID
  final String firstMessageContent; // 최초 메시지 내용
  final String originalMessageContent; // 원본 메시지 내용
  final String convertMessageContent; // 변환된 메시지 내용 (예: 부정 메시지 수정 후)
  final String timestamp; // 메시지 전송 시각
  final bool isConvertMessage; // 메시지가 변환되었는지 여부
  final String originalSentiment; // 원본 메시지의 감정 분석 결과
  final String sendMessageSentiment; // 전송 메시지의 감정 분석 결과
  final int backspaceCount; // 입력 중 백스페이스 사용 횟수
  final int refreshMessage; // 메시지 새로고침 횟수

  const FirebaseMessageSaveEvent({
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

// 추천 메시지 요청 이벤트: 부정 메시지에 대한 대체 메시지 생성 요청
class LlmRecommendMessageEvent extends MessageSendEvent {
  final String negativeMessage; // 부정적인 메시지 내용
  final String roomId; // 채팅방 ID

  const LlmRecommendMessageEvent(this.negativeMessage, this.roomId);
}

// 상태 정의: 메시지 전송 및 처리 과정의 상태를 나타냄
abstract class MessageSendState {
  const MessageSendState();
}

// 초기 상태: 메시지 전송 프로세스가 시작되기 전
class MessageSendInitialState extends MessageSendState {
  const MessageSendInitialState();
}

// 처리 중 상태: 메시지 처리(분석, 저장 등)가 진행 중
class MessageSendProcessingState extends MessageSendState {
  const MessageSendProcessingState();
}

// 감정 분석 성공 상태: 텍스트의 감정 분석 결과 반환
class AzureSentimentAnalysisSuccessState extends MessageSendState {
  final String analysisResult; // 감정 분석 결과 (예: "positive", "negative")

  const AzureSentimentAnalysisSuccessState(this.analysisResult);
}

// 에러 상태: 처리 중 오류 발생 시
class MessageSendErrorState extends MessageSendState {
  final String error; // 오류 메시지

  const MessageSendErrorState(this.error);
}

// LLM 메시지 전송 성공 상태: 추천 메시지 생성 완료
class LlmMessageSentState extends MessageSendState {
  final String response; // LLM이 생성한 추천 메시지

  const LlmMessageSentState(this.response);
}

// Firebase 메시지 저장 성공 상태: 메시지가 Firebase에 저장됨
class FirebaseMessageSaveSentState extends MessageSendState {
  const FirebaseMessageSaveSentState();
}

// BLoC 클래스: 메시지 전송 및 감정 분석 로직 관리
class MessageSendBloc extends Bloc<MessageSendEvent, MessageSendState> {
  final MessageGenerationService
      messageGenerationService; // LLM 서비스 (추천 메시지 생성)
  final GoogleNLPService googleNLPService; // 감정 분석 서비스
  final DatabaseReference databaseReference; // Firebase 데이터베이스 참조
  final MessageReceiveBloc messageReceiveBloc; // 수신 메시지 관리 BLoC
  final AuthenticationBloc authBloc; // 사용자 인증 상태 관리 BLoC

  MessageSendBloc({
    required this.messageGenerationService,
    required this.googleNLPService,
    required this.databaseReference,
    required this.messageReceiveBloc,
    required this.authBloc,
  }) : super(const MessageSendInitialState()) {
    // 이벤트 핸들러 등록
    on<AzureSentimentAnalysisEvent>(_handleAzureSentimentAnalysis);
    on<FirebaseMessageSaveEvent>(_handleFirebaseMessageSave);
    on<LlmRecommendMessageEvent>(_handleLlmRecommendMessage);
  }

  // 감정 분석 이벤트 처리: 입력 텍스트의 감정을 분석
  Future<void> _handleAzureSentimentAnalysis(
    AzureSentimentAnalysisEvent event,
    Emitter<MessageSendState> emit,
  ) async {
    emit(const MessageSendProcessingState()); // 처리 중 상태로 전환
    try {
      final analysisResult =
          await googleNLPService.analyzeSentiment(event.text);
      emit(AzureSentimentAnalysisSuccessState(analysisResult)); // 분석 결과 반환
    } catch (e) {
      emit(MessageSendErrorState(e.toString())); // 오류 발생 시 에러 상태
    }
  }

  // 추천 메시지 생성 이벤트 처리: 부정 메시지에 대한 대체 메시지 생성
  Future<void> _handleLlmRecommendMessage(
    LlmRecommendMessageEvent event,
    Emitter<MessageSendState> emit,
  ) async {
    emit(const MessageSendProcessingState()); // 처리 중 상태로 전환
    try {
      final currentUser = _getCurrentUserName(); // 현재 사용자 이름 가져오기
      final previousMessages =
          _getPreviousMessages(currentUser); // 이전 대화 내용 가져오기

      // LLM을 통해 부정 메시지에 대한 추천 메시지 생성
      final response = await messageGenerationService.generateResponse(
        event.negativeMessage,
        previousMessages,
      );

      // 생성된 추천 메시지를 Firebase에 저장
      await _saveGptMessageToFirebase(
          event.roomId, event.negativeMessage, response);
      emit(LlmMessageSentState(response)); // 성공 상태로 전환
    } catch (e) {
      emit(MessageSendErrorState(e.toString())); // 오류 발생 시 에러 상태
    }
  }

  // 메시지 저장 이벤트 처리: 채팅 메시지를 Firebase에 저장
  Future<void> _handleFirebaseMessageSave(
    FirebaseMessageSaveEvent event,
    Emitter<MessageSendState> emit,
  ) async {
    emit(const MessageSendProcessingState()); // 처리 중 상태로 전환
    try {
      await _saveMessageToFirebase(event); // 메시지 저장
      await _updateLastMessage(event); // 마지막 메시지 정보 업데이트
      emit(const FirebaseMessageSaveSentState()); // 성공 상태로 전환
    } catch (e) {
      emit(MessageSendErrorState(e.toString())); // 오류 발생 시 에러 상태
    }
  }

  // 현재 사용자 이름 가져오기
  String _getCurrentUserName() {
    final currentState = authBloc.state;
    if (currentState is AuthenticationSuccess) {
      return currentState.user.displayName ?? 'Unknown';
    }
    return 'Unknown';
  }

  // 이전 대화 내용 가져오기 (최대 20개로 제한)
  List<String> _getPreviousMessages(String currentUser) {
    var messages = messageReceiveBloc.previousMessages.map((message) {
      final prefix = message.senderName == currentUser ? '나' : '상대방'; // 발신자 구분
      final content = message.isConvertMessage
          ? message.convertMessageContent
          : message.originalMessageContent;
      return '$prefix: $content';
    }).toList();

    if (messages.length > 20) {
      messages = messages.sublist(messages.length - 20); // 최근 20개만 사용
    }
    return messages;
  }

  // LLM 추천 메시지를 Firebase에 저장
  Future<void> _saveGptMessageToFirebase(
    String roomId,
    String negativeMessage,
    String response,
  ) async {
    final gptMessageRef =
        databaseReference.child('chat_rooms/$roomId/gpt_messages').push();
    await gptMessageRef.set({
      'originalMessageContent': negativeMessage, // 원본 부정 메시지
      'messages': response, // 추천 메시지
      'timestamp': DateTime.now().toString(), // 저장 시각
    });
  }

  // 채팅 메시지를 Firebase에 저장
  Future<void> _saveMessageToFirebase(FirebaseMessageSaveEvent event) async {
    final messageRef =
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
  }

  // 채팅방의 마지막 메시지 정보 업데이트
  Future<void> _updateLastMessage(FirebaseMessageSaveEvent event) async {
    final lastMessageRef =
        databaseReference.child('chat_rooms/${event.roomId}/last_message');
    final lastMessageTimestampRef = databaseReference
        .child('chat_rooms/${event.roomId}/last_message_timestamp');

    final lastMessageContent = event.isConvertMessage
        ? event.convertMessageContent
        : event.originalMessageContent;

    await lastMessageRef.set(lastMessageContent); // 마지막 메시지 내용 업데이트
    await lastMessageTimestampRef.set(event.timestamp); // 마지막 메시지 타임스탬프 업데이트
  }
}
