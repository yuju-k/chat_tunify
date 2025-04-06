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
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isRegistering ? null : _register,
      child: const Text('회원등록'),
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
      appBar: AppBar(title: const Text('회원가입')),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  validator: _validateEmail,
                ),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  validator: _validatePassword,
                  obscureText: true,
                ),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
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
          ),
        ),
      ),
    );
  }
}
