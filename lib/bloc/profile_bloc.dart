import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

//** 프로필 업데이트 이벤트 //
abstract class ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String name;
  final String statusMessage;
  final File? image;
  final String currentImageUrl;
  final String uid;
  final String email;

  ProfileUpdateRequested(
    this.name,
    this.statusMessage,
    this.image,
    this.currentImageUrl,
    this.uid,
    this.email,
  );
}

class ProfileLoaded extends ProfileState {
  final String name;
  final String statusMessage;
  final String imageUrl;
  final String email;
  final String uid;

  ProfileLoaded(
      this.name, this.statusMessage, this.imageUrl, this.email, this.uid);
}

//** 프로필 상태 //
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {}

class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure(this.error);
}

class ProfileLoadRequested extends ProfileEvent {
  final String email;

  ProfileLoadRequested(this.email);
}

//** 프로필관련 BLoC //
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileLoadRequested(
      ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('user_profile')
          .doc(event.email)
          .get();

      if (profileSnapshot.exists) {
        var profileData = profileSnapshot.data() as Map<String, dynamic>;
        emit(ProfileLoaded(
          profileData['name'] ?? '',
          profileData['statusMessage'] ?? '',
          profileData['imageUrl'] ?? '',
          profileData['email'] ?? '',
          profileData['uid'] ?? '',
        ));
      } else {
        emit(ProfileInitial());
      }
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> _onProfileUpdateRequested(
      ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      String imageUrl = event.currentImageUrl;
      if (event.image != null) {
        imageUrl = await _uploadImageToFirebaseStorage(event.image!);
      }

      await _saveProfileInfoToFirestore(
          event.name, event.statusMessage, imageUrl);

      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<String> _uploadImageToFirebaseStorage(File image) async {
    String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref =
        FirebaseStorage.instance.ref().child('profiles').child(fileName);

    UploadTask uploadTask = ref.putFile(image);
    await uploadTask.whenComplete(() {});

    return await ref.getDownloadURL();
  }

  Future<void> _saveProfileInfoToFirestore(
      String name, String statusMessage, String imageUrl) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? '';

      DocumentReference profileDoc =
          FirebaseFirestore.instance.collection('user_profile').doc(email);

      await profileDoc.set({
        'email': email,
        'imageUrl': imageUrl,
        'name': name,
        'statusMessage': statusMessage,
        'uid': user.uid,
      });
    } else {
      throw Exception('No user logged in');
    }
  }
}
