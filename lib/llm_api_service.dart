import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

//감정 판독
class AzureSentimentAnalysisService {
  final String _azureApiKey = dotenv.env['AZURE_API_KEY']!;
  final String _azureEndpoint = dotenv.env['AZURE_END_POINT']!;
  final String _azureSentimentPath = dotenv.env['AZURE_SENTIMENT_PATH']!;

  Future<String> analyzeSentiment(String text) async {
    final uri = Uri.parse('$_azureEndpoint$_azureSentimentPath');
    final headers = {
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Key': _azureApiKey,
    };
    final requestBody = jsonEncode({
      'documents': [
        {'id': '1', 'language': 'ko', 'text': text},
      ],
    });

    try {
      final response =
          await http.post(uri, headers: headers, body: requestBody);
      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        String sentimentLabel = responseJson['documents'][0]['sentiment'];
        return sentimentLabel;
      } else {
        return 'Failed to analyze sentiment. Status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'error : \'Exception caught: $e';
    }
  }
}

//메시지변환
class ChatGPTService {
  // OpenAI API의 엔드포인트 URL
  final String _baseUrl = dotenv.env['OPENAI_END_POINT']!;
  // OpenAI API 키
  final String _apiKey = dotenv.env['OPENAI_API_KEY']!;

  // 추천메시지 요청 API
  Future<String> recommandMessageRequest(
      String message, List<String> previousMessages) async {
    try {
      // HTTP 요청을 위한 헤더 설정
      final headers = {
        //'Content-Type': 'application/json',
        //인코딩
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_apiKey'
      };

      // 이전 대화 내용
      List<Map<String, String>> messages = previousMessages
          .map((msg) => {"role": "user", "content": msg})
          .toList();

      // 시스템 지침 추가
      messages.add({
        "role": "system",
        "content":
            "당신은 '나'의 메시지를 입력받을 것입니다. 상대방의 예상되는 감정을 한 단어로 이야기 해주세요. 단어만 출력하세요."
      });

      // 현재 사용자 메시지 추가
      messages.add({"role": "user", "content": message});

      // 요청 본문 구성
      final body = jsonEncode({
        "model": "gpt-4",
        "messages": messages,
        "temperature": 1,
        "max_tokens": 100,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0.5
      });

      //print(body);

      // HTTP POST 요청 보내기
      final response =
          await http.post(Uri.parse(_baseUrl), headers: headers, body: body);

      // 응답 확인 및 처리
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        //print(utf8.decode(response.bodyBytes));

        // 'choices' 배열의 첫 번째 요소의 'content' 값 추출
        if (jsonResponse['choices'] != null &&
            jsonResponse['choices'].isNotEmpty) {
          return jsonResponse['choices'][0]['message']['content'];
        } else {
          return 'No content found';
        }
      } else {
        return 'Error: ${response.statusCode}, Body: ${response.body}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
