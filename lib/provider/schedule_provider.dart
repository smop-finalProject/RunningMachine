import 'package:flutter/cupertino.dart';
import 'package:lastsub/repository/auth_repository.dart';

class ScheduleProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  String? accessToken;
  String? refreshToken;

  ScheduleProvider({

    required this.authRepository,
  });

  void updateTokens({
    String? refreshToken,
    String? accessToken,
  }) {
    if (refreshToken != null) {
      this.refreshToken = refreshToken;
    }

    if (accessToken != null) {
      this.accessToken = accessToken;
    }

    notifyListeners();
  }
}