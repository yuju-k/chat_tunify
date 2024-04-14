class Message {
  final String senderName; //보낸사람
  final String senderUID; //보낸사람 UID
  final String senderEmail; //보낸사람 이메일
  final String originalMessageContent; //원본 메시지
  final String convertMessageContent; //변경된 메시지(추천메시지 내용)
  final bool isConvertMessage; //변환된 메시지인가?
  final String originalSentiment; //원본 말투 분석 결과
  final String sendMessageSentiment; //보낸 메시지 말투 분석 결과 (최종)
  final String timestamp; //타임스탬프 (보낸 시간)
  final int backspaceCount; //메시지 전송까지 백스페이스 누른 횟수
  final int refreshMessage; //메시지에서 새로고침 누른 횟수

  Message({
    required this.senderName,
    required this.senderUID,
    required this.senderEmail,
    required this.originalMessageContent,
    required this.convertMessageContent,
    required this.isConvertMessage,
    required this.originalSentiment,
    required this.sendMessageSentiment,
    required this.timestamp,
    required this.backspaceCount,
    required this.refreshMessage,
  });

  factory Message.fromMap(Map<dynamic, dynamic> map) {
    return Message(
      senderName: map['senderName'] as String,
      senderUID: map['senderUID'] as String,
      originalMessageContent: map['originalMessageContent'] as String,
      convertMessageContent: map['convertMessageContent'] as String,
      timestamp: map['timestamp'] as String,
      isConvertMessage: map['isConvertMessage'] as bool,
      originalSentiment: map['originalSentiment'] as String,
      sendMessageSentiment: map['sendMessageSentiment'] as String,
      senderEmail: map['senderEmail'] as String,
      backspaceCount: map['backspaceCount'] as int,
      refreshMessage: map['refreshMessage'] as int,
    );
  }
}

List<Message> messages = [];
