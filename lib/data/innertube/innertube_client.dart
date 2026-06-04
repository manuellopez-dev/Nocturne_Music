import 'package:dio/dio.dart';

class InnerTubeClient {
  static const _baseUrl = 'https://music.youtube.com/youtubei/v1';

  late final Dio _dio;
  String? _accessToken;

  InnerTubeClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));
  }

  void setAccessToken(String token) {
    _accessToken = token;
    print('[InnerTube] Token configurado: ${token.substring(0, 20)}...');
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': 'es-MX,es;q=0.9',
      'Origin': 'https://music.youtube.com',
      'Referer': 'https://music.youtube.com/',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      'X-Goog-Api-Format-Version': '1',
      'X-YouTube-Client-Name': '67',
      'X-YouTube-Client-Version': '1.20250101.01.00',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
      headers['X-Goog-AuthUser'] = '0';
    }

    return headers;
  }

  Map<String, dynamic> _buildContext() {
    return {
      'context': {
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': '1.20250101.01.00',
          'hl': 'es',
          'gl': 'MX',
          'platform': 'DESKTOP',
          'userAgent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36,gzip(gfe)',
        },
      },
    };
  }

  Future<Map<String, dynamic>> search(String query) async {
    final headers = _buildHeaders();
    final body = _buildContext();
    body['query'] = query;

    print('[InnerTube] Authorization presente: ${headers.containsKey('Authorization')}');
    print('[InnerTube] Query: $query');

    try {
      final response = await _dio.post(
        '/search',
        options: Options(headers: headers),
        data: body,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('[InnerTube] ERROR ${e.response?.statusCode}: ${e.response?.data}');
      throw Exception('Error del servidor: ${e.response?.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getNext(String videoId) async {
    final headers = _buildHeaders();
    final body = _buildContext();
    body['videoId'] = videoId;
    body['isAudioOnly'] = true;

    try {
      final response = await _dio.post(
        '/next',
        options: Options(headers: headers),
        data: body,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Error del servidor: ${e.response?.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getHome() async {
    final headers = _buildHeaders();
    final body = _buildContext();
    body['browseId'] = 'FEmusic_home';

    try {
      final response = await _dio.post(
        '/browse',
        options: Options(headers: headers),
        data: body,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Error del servidor: ${e.response?.statusCode}');
    }
  }
}