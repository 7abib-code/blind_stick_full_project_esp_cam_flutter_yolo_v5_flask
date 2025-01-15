import 'package:http/http.dart' as http;

class VideoServer {
  final String _baseUrl = 'http://192.168.43.129:81';

  Future<http.Response> getVideo(String videoId) async {
    final url = '$_baseUrl/$videoId';
    final response = await http.get(Uri.parse(url));
    return response;
  }
}