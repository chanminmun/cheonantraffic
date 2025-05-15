import 'package:http/http.dart' as http_pk;
import 'dart:convert';

class Network {
  final String url; // 날씨 정보 URL

  // 생성자: 주소를 받아 초기화
  Network(this.url);

  // 날씨와 온도 정보만 가져오기
  Future<Map<String, dynamic>?> getWeatherData() async {
    try {
      final response = await http_pk.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // 필요한 데이터만 추출
        String weatherDescription = data['weather'][0]['description']; // 날씨 설명
        double temperature = data['main']['temp']; // 온도

        return {
          'description': weatherDescription,
          'temperature': temperature,
        };
      } else {
        throw Exception('Failed to load weather data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
    }
  }
}
