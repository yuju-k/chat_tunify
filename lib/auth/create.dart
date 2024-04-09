import 'package:flutter/material.dart';
import 'package:chat_tunify/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _isRegistering = false;

  static const _emailEmptyError = 'Please enter your email';
  static const _emailInvalidError = 'Please enter a valid email';
  static const _passwordEmptyError = 'Please enter your password';
  static const _passwordLengthError = 'Password must be at least 6 characters';
  static const _confirmPasswordEmptyError = 'Please confirm your password';
  static const _passwordMismatchError = 'Passwords do not match';

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_passwordMismatchError)),
      );
      return;
    }

    setState(() => _isRegistering = true);
    Navigator.pushNamed(context, '/create_profile');
    BlocProvider.of<AuthenticationBloc>(context).add(
      SignUpRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) return _emailEmptyError;
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return _emailInvalidError;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value!.isEmpty) return _passwordEmptyError;
    if (value.length < 6) return _passwordLengthError;
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value!.isEmpty) return _confirmPasswordEmptyError;
    if (_passwordController.text != value) return _passwordMismatchError;
    return null;
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'Email'),
        validator: _validateEmail,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
        validator: _validatePassword,
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Confirm Password'),
        validator: _validateConfirmPassword,
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
        if (state is AuthenticationLoading) {
          return const CircularProgressIndicator();
        }
        return Container();
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
                _buildEmailField(),
                _buildPasswordField(),
                _buildConfirmPasswordField(),
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
