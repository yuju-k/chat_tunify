import 'package:flutter/material.dart';
import 'package:chat_tunify/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // Form controllers and state
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isRegistering = false;

  // Validation messages
  static const Map<String, String> _validationMessages = {
    'emailEmpty': 'Please enter your email',
    'emailInvalid': 'Please enter a valid email',
    'passwordEmpty': 'Please enter your password',
    'passwordLength': 'Password must be at least 6 characters',
    'confirmEmpty': 'Please confirm your password',
    'passwordMismatch': 'Passwords do not match',
  };

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return _validationMessages['emailEmpty'];
    }
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return _validationMessages['emailInvalid'];
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _validationMessages['passwordEmpty'];
    }
    if (value.length < 6) {
      return _validationMessages['passwordLength'];
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return _validationMessages['confirmEmpty'];
    }
    if (value != _passwordController.text) {
      return _validationMessages['passwordMismatch'];
    }
    return null;
  }

  // Registration logic
  void _register() {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isRegistering = true);
    Navigator.pushNamed(context, '/create_profile');

    BlocProvider.of<AuthenticationBloc>(context).add(
      SignUpRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  // UI Components
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF44C2D0), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF44C2D0), width: 2.0),
          ),
          filled: true, // 바탕색 채우기 활성화
          fillColor: Colors.white, // 바탕색을 흰색으로 설정
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isRegistering ? null : _register,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor:
            const Color(0xFF44C2D0), // 버튼 배경 색상 (테마의 seedColor과 유사)
        foregroundColor: Colors.white,
        minimumSize: const Size(350, 50),
      ),
      child: const Text('회원등록',
          style: TextStyle(
            fontSize: 16,
          )),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/login'),
      child: const Text('이미 계정이 있으신가요? 로그인하기'),
    );
  }

  Widget _buildLoadingIndicator() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return state is AuthenticationLoading
            ? const CircularProgressIndicator()
            : const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is! AuthenticationLoading) {
            setState(() => _isRegistering = false);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 120.0),
          child: Form(
            key: _formKey,
            child: Stack(children: [
              // assets/images/Moodwave_logo.png 넣기
              Column(
                // 정렬 위쪽부터
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/Moodwave_logo.png',
                      width: 250,
                    ),
                  ),
                ],
              ),
              // 네모박스
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 220),
                    Container(
                      width: 480,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8F3F1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Image.asset(
                                'assets/images/join.png',
                                width: 100,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTextField(
                                controller: _emailController,
                                label: '이메일',
                                validator: _validateEmail,
                              ),
                              _buildTextField(
                                controller: _passwordController,
                                label: '비밀번호',
                                validator: _validatePassword,
                                obscureText: true,
                              ),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: '비밀번호 확인',
                                validator: _validateConfirmPassword,
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
                              _buildRegisterButton(),
                              const SizedBox(height: 20),
                              _buildLoginButton(),
                              _buildLoadingIndicator(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
