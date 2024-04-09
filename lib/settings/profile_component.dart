import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_tunify/bloc/profile_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileComponent extends StatefulWidget {
  const ProfileComponent({super.key});

  @override
  State<ProfileComponent> createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  File? _image; // 선택된 이미지 파일
  String _imageUrl = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Initialize with empty controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusMessageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Request the profile for the current user
      context.read<ProfileBloc>().add(ProfileLoadRequested(user.email!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusMessageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showFullImage() {
    if (_image != null || _imageUrl.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child:
                _image != null ? Image.file(_image!) : Image.network(_imageUrl),
          ),
        );
      }));
    }
  }

  // 이미지를 삭제하는 메소드
  void _deleteImage() {
    setState(() {
      _image = null; // 선택된 파일 이미지 삭제
      _imageUrl = ''; // 이미지 URL 초기화
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _nameController.text = state.name;
          _statusMessageController.text = state.statusMessage;

          // No need to download the image file; just update the UI with the new URL
          setState(() {
            _imageUrl = state
                .imageUrl; // Make sure to declare _imageUrl in your state class
          });
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const CircularProgressIndicator();
        }
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('프로필 설정',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Text('프로필을 변경하려면 아래의 정보를 입력하세요.'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15.0),

                // 프로필 사진 위젯
                GestureDetector(
                  onTap: () => _showFullImage(),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(
                        color: Colors.blueGrey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_imageUrl.isNotEmpty
                                  ? NetworkImage(_imageUrl)
                                  : const AssetImage(
                                      'assets/images/default_profile.png'))
                              as ImageProvider,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    '프로필 사진 변경',
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                // 이미지가 선택되었거나 URL이 있는 경우에만 삭제 버튼 표시
                if (_image != null || _imageUrl.isNotEmpty)
                  ElevatedButton(
                    onPressed: _deleteImage,
                    child: const Text('기본 프로필 사진으로 변경'),
                  ),

                const SizedBox(height: 20.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    label: Text('이름'),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Update the name in the state
                  },
                ),

                const SizedBox(height: 20.0),

                TextField(
                  controller: _statusMessageController,
                  decoration: const InputDecoration(
                    label: Text('상태 메시지'),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Update the status message in the state
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<ProfileBloc>().add(
                            ProfileUpdateRequested(
                              _nameController.text,
                              _statusMessageController.text,
                              _image,
                              _imageUrl,
                              FirebaseAuth.instance.currentUser!.uid,
                              FirebaseAuth.instance.currentUser!.email!,
                            ),
                          );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('프로필 저장'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
