import 'dart:io';
import 'package:dio/dio.dart';

class AuthRepository {
  // Dio 인스턴스 생성
  final _dio = Dio();

  // 서버 주소
  final _targetUrl = 'http://${Platform.isAndroid ? '10.0.2.2' : 'localhost'}:3000/auth';

  // 리프레시 토큰을 이용한 토큰 재발급 로직
  Future<String> rotateRefreshToken({
    required String refreshToken,
  }) async {
    // 리프레시 토큰을 헤더에 담아 리프레시 토큰 재발급 URL에 요청
    final result = await _dio.post(
      '$_targetUrl/token/refresh',
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );

    // 새 리프레시 토큰 반환
    return result.data['refreshToken'] as String;
  }

  Future<String> rotateAccessToken({
    required String refreshToken,
  }) async {
    // 리프레시 토큰을 헤더에 담아 엑세스 토큰 재발급 URL에 요청
    final result = await _dio.post(
      '$_targetUrl/token/access',
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );

    // 새 엑세스 토큰 반환
    return result.data['accessToken'] as String;
  }
}