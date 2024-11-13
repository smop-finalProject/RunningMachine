import 'package:lastsub/const/colors.dart';
import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget{
  final FormFieldSetter<String?> onSaved;
  final FormFieldValidator<String?> validator;
  final String? hinText;
  final bool obscureText;

  const LoginTextField({
    required this.onSaved,
    required this.validator,
    this.obscureText = false,
    this.hinText,
    Key ? key,
  }): super (key: key);
  @override
  Widget build(BuildContext context){
    return TextFormField(
      //텍스트 필드값을 저장할 때 실행할 함수
      onSaved: onSaved,
      // 텍스트 검증할 때 실행
      validator: validator,
      cursorColor: SECONDARY_COLOR,
      //텍스트 필드에 입력된 값이 ture일 경우 보이지 않도록 설정
      obscureText: obscureText,
      decoration: InputDecoration(
        // 텍스트 필드에 아무것도 입력하지 않았을 때 보여주는 힌트 문자
        hintText: hinText,
        //활성화된 상태의 보더
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: TEXT_FIELD_FILL_COLOR,
          ),
        ),
        //포커싱 된 상태의 보더(텍스트 필드를 탭하면 보더가 포커스된 상태로 변하며 커서가 활성화되어 문자를 입력할 수 있는 상태)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: SECONDARY_COLOR,
          ),
        ),
        //에러 상태 보더
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: ERROR_COLOR,
          ),
        ),

        //포커스된 상태에서 에러가 났을 때 보더
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: ERROR_COLOR,
          ),
        ),
      ),
    );
  }
}