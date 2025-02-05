import 'package:flutter/material.dart';
import 'package:chat_tunify/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // Controllers & State
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _isRegistering = false;

  // Validation Messages
  static const _validationMessages = {
    'emailEmpty': 'Please enter your email',
    'emailInvalid': 'Please enter a valid email',
    'passwordEmpty': 'Please enter your password',
    'passwordLength': 'Password must be at least 6 characters',
    'confirmEmpty': 'Please confirm your password',
    'passwordMismatch': 'Passwords do not match'
  };

  // Form Validation Methods
  String? _validateEmail(String? value) {
    if (value!.isEmpty) return _validationMessages['emailEmpty'];
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return _validationMessages['emailInvalid'];
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value!.isEmpty) return _validationMessages['passwordEmpty'];
    if (value.length < 6) return _validationMessages['passwordLength'];
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value!.isEmpty) return _validationMessages['confirmEmpty'];
    if (_passwordController.text != value) {
      return _validationMessages['passwordMismatch'];
    }
    return null;
  }

  // Register Logic
  void _register() {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:
        Text(_validationMessages['passwordMismatch']!)),
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

  // UI Components
  Widget _buildEmailField() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: _validateEmail,
    ),
  );

  Widget _buildPasswordField() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Password'),
      validator: _validatePassword,
    ),
  );

  Widget _buildConfirmPasswordField() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Confirm Password'),
      validator: _validateConfirmPassword,
    ),
  );

  Widget _buildRegisterButton() => ElevatedButton(
    onPressed: _isRegistering ? null : _register,
    child: const Text('회원등록'),
  );

  Widget _buildLoginButton() => TextButton(
    onPressed: () => Navigator.pushNamed(context, '/login'),
    child: const Text('이미 계정이 있으신가요? 로그인하기'),
  );

  Widget _buildLoadingIndicator() => BlocBuilder<AuthenticationBloc, AuthenticationState>(
    builder: (context, state) => state is AuthenticationLoading
        ? const CircularProgressIndicator()
        : Container(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('회원가입', style: TextStyle(color: Colors.lightGreen)),
      ),
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
