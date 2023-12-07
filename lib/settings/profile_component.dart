import 'package:flutter/material.dart';

class ProfileComponent extends StatefulWidget {
  const ProfileComponent({super.key});

  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  String _name = '';
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('[Title]', style: Theme.of(context).textTheme.titleLarge),
        Text('프로필을 변경하려면 아래의 정보를 입력하세요.'),

        SizedBox(height: 8.0),
        // TODO: 프로필 사진 변경 버튼 추가
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            border: Border.all(
              color: Colors.lightBlue,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://picsum.photos/200'),
          ),
        ),
        ElevatedButton(onPressed: () {}, child: Text('프로필 사진 변경')),

        SizedBox(height: 20.0),

        TextField(
          decoration: InputDecoration(
            label: Text('이름'),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),

        SizedBox(height: 20.0),

        TextField(
          decoration: InputDecoration(
            label: Text('상태 메시지'),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _statusMessage = value;
            });
          },
        ),

        SizedBox(height: 16.0),
        //변경버튼
        ElevatedButton(
          onPressed: () {},
          child: Text('프로필 저장'),
        ),
      ],
    );
  }
}
