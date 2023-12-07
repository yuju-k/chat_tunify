import 'package:flutter/material.dart';

class ProfileComponent extends StatefulWidget {
  const ProfileComponent({super.key});

  @override
  State<ProfileComponent> createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  String _name = '박건우';
  String _statusMessage = '현재 행복함';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('프로필 설정', style: Theme.of(context).textTheme.titleLarge),
                  const Text('프로필을 변경하려면 아래의 정보를 입력하세요.'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15.0),

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
          ElevatedButton(
              onPressed: () {},
              child: const Text('프로필 사진 변경',
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              )),

          const SizedBox(height: 20.0),

          TextField(
            controller: TextEditingController(text: _name),
            decoration: const InputDecoration(
              label: Text('이름'),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
          ),

          const SizedBox(height: 20.0),

          TextField(
            controller: TextEditingController(text: _statusMessage),
            decoration: const InputDecoration(
              label: Text('상태 메시지'),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _statusMessage = value;
              });
            },
          ),

          const SizedBox(height: 16.0),
          //변경버튼
          ElevatedButton(
            onPressed: () {},
            child: const Text('프로필 저장'),
          ),
        ],
      ),
    );
  }
}
