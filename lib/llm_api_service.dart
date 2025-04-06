import 'package:firebase_vertexai/firebase_vertexai.dart';

// 감정 분석(Sentiment Analysis) 서비스
class GoogleNLPService {
  late final GenerativeModel _model;

  GoogleNLPService() {
    _model =
        FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
  }

  /// 주어진 텍스트의 감정을 분석하여 'negative', 'neutral', 'positive' 중 하나를 반환합니다.
  Future<String> analyzeSentiment(String text) async {
    try {
      final prompt = [
        Content.text(
            '''다음 텍스트의 감정을 분석하여 'negative', 'neutral', 'positive' 중 하나만 출력하세요. 다른 텍스트는 포함시키지 마세요.

텍스트: $text'''),
      ];

      final response = await _model.generateContent(prompt);
      final sentiment = response.text?.trim().toLowerCase() ?? 'neutral';

      if (!['negative', 'neutral', 'positive'].contains(sentiment)) {
        return 'neutral'; // 모델이 예상치 못한 응답을 반환할 경우 기본값
      }
      return sentiment;
    } catch (e) {
      print('Sentiment analysis error: $e');
      return 'neutral'; // 에러 발생 시 기본값 반환
    }
  }
}

// 메시지 생성 서비스
class MessageGenerationService {
  late final GenerativeModel _model;

  MessageGenerationService() {
    _model =
        FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
  }

  /// 주어진 메시지와 이전 대화를 기반으로 새로운 메시지를 생성합니다.
  /// 부정 메시지에 대한 추천 로직은 포함하지 않으며, 호출자가 결과를 처리합니다.
  Future<String> generateResponse(
      String message, List<String> previousMessages) async {
    try {
      final prompt = [
        Content.text(
            '''다음 대화 맥락을 고려하여 입력 메시지를 긍정적이거나 중립적인 톤으로 변환한 메시지를 생성하세요. 변환된 메시지만 출력하세요.

이전 대화:
${previousMessages.join('\n')}

입력 메시지: $message'''),
      ];

      final response = await _model.generateContent(prompt);
      return response.text?.trim() ?? message; // 생성된 메시지 반환, 실패 시 원본 반환
    } catch (e) {
      print('Message generation error: $e');
      return message; // 에러 발생 시 원본 메시지 반환
    }
  }
}
