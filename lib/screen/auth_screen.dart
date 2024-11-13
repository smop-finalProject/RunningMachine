import 'package:lastsub/component/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lastsub/const/colors.dart';
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 기존 Column을 SingleChildScrollView로 감싸서 스크롤 가능하게 만듦(책에만 있고 안배움)
      body: SingleChildScrollView( // 화면이 작을 때 스크롤할 수 있도록 함
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/img/logo1.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
              const SizedBox(height: 16.0),
              LoginTextField(
                onSaved: (String? val) {},
                validator: (String? val) {},
                hinText: '이메일',
              ),
              const SizedBox(height: 8.0),
              LoginTextField(
                obscureText: true,
                onSaved: (String? val) {},
                validator: (String? val) {},
                hinText: '비밀번호',
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: SECONDARY_COLOR,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () {},
                child: Text('회원 가입'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: SECONDARY_COLOR,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () {},
                child: Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}