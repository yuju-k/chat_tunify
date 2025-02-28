import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

//프로젝트 최상위 폴더에 .env 파일을 추가하세요.
//-- .env 파일 내용 --
// GOOGLE_API_KEY=your_azure_api_key_here
// GOOGLE_NLP_ENDPOINT=https://language.googleapis.com/v2/documents:analyzeSentiment
//

//감정 판독(Sentiment Analysis) API
class GoogleNLPService {
  final String _googleApiKey = dotenv.env['GOOGLE_API_KEY']!;
  final String _googleNlpEndpoint = dotenv.env['GOOGLE_NLP_ENDPOINT']!;

  Future<String> analyzeSentiment(String text) async {
    final uri = Uri.parse('$_googleNlpEndpoint?key=$_googleApiKey');
    final headers = {
      'Content-Type': 'application/json',
    };
    final requestBody = jsonEncode({
      'document': {
        'type': 'PLAIN_TEXT',
        'content': text,
        'language': 'ko'
      },
      'encodingType': 'UTF8'
    });

    try {
      final response = await http.post(uri, headers: headers, body: requestBody);
      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        double score = responseJson['documentSentiment']['score'];
        String sentimentLabel = _getSentimentLabel(score);
        return sentimentLabel;
      } else {
        return 'Failed to analyze sentiment. Status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'error : Exception caught: $e';
    }
  }

  String _getSentimentLabel(double score) {
    if (score > 0.25) return 'positive';
    if (score < -0.25) return 'negative';
    return 'neutral';
  }
}

// 감정 생성 서비스
class MessageGenerationService {
  late final GenerativeModel _model;

  MessageGenerationService() {
    _model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
  }

  Future<String> generateResponse(String message, List<String> previousMessages) async {
    try {
      final prompt = [
        Content.text(
            '''당신은 '나'의 메시지를 입력받을 것입니다. 상대방의 예상되는 감정을 한 단어로 이야기 해주세요. 단어만 출력하세요.

이전 대화:
${previousMessages.join('\n')}

현재 메시지: $message'''
        )
      ];

      final response = await _model.generateContent(prompt);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
