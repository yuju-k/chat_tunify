import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String _serverResponse = 'Server response';

  Future<void> testApiConnection() async {
    var url = Uri.parse('http://192.168.0.7:8080/ping');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _serverResponse = 'Server Response: ${response.body}';
      });
    } else {
      setState(() {
        _serverResponse = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: testApiConnection,
              child: Text('Test API Connection'),
            ),
            SizedBox(height: 20),
            Text(_serverResponse),
          ],
        ),
      ),
    );
  }
}
