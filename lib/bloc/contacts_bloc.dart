import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Events
abstract class ContactsEvent {}

class LoadContacts extends ContactsEvent {}

class SearchContacts extends ContactsEvent {
  final String query;
  SearchContacts(this.query);
}

// States
abstract class ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<Map<String, dynamic>> contacts;

  ContactsLoaded({required this.contacts});
}

class ContactsSearchResults extends ContactsState {
  final List<Map<String, dynamic>> searchResults;

  ContactsSearchResults({required this.searchResults});
}

class ContactsFailure extends ContactsState {
  final String error;

  ContactsFailure({required this.error});
}

//** 사용자 추가 */
class AddUser extends ContactsEvent {
  final String userEmail;
  AddUser(this.userEmail);
}

// 로딩중
class AddUserLoading extends ContactsState {}

class AddUserSuccess extends ContactsState {
  final String userEmail;
  AddUserSuccess(this.userEmail);
}

class AddUserFailure extends ContactsState {
  final String error;
  AddUserFailure(this.error);
}

// Bloc
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  List<Map<String, dynamic>> allContacts = [];

  ContactsBloc({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(ContactsLoading()) {
    on<LoadContacts>(_loadContacts);
    on<SearchContacts>(_searchContacts);
    on<AddUser>(_addUser);
  }

  Future<void> _addUser(AddUser event, Emitter<ContactsState> emit) async {
    emit(AddUserLoading());
    try {
      var user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if the user is trying to add themselves
      if (user.email == event.userEmail) {
        throw Exception('You cannot add yourself as a friend');
      }

      DocumentSnapshot friendProfileDoc = await _firestore
          .collection('user_profile')
          .doc(event.userEmail)
          .get();

      if (!friendProfileDoc.exists) {
        throw Exception('User not found');
      }

      // Get the current user's friends document
      DocumentReference userFriendsRef =
          _firestore.collection('friends').doc(user.email);
      DocumentSnapshot userFriendsSnapshot = await userFriendsRef.get();

      if (!userFriendsSnapshot.exists) {
        // If the friends document doesn't exist, create it with the new friend's email
        await userFriendsRef.set({
          'email': [event.userEmail],
        });
      } else {
        // If the friends document exists, update it with the new friend's email
        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot freshSnap = await transaction.get(userFriendsRef);
          if (!freshSnap.exists) {
            throw Exception(
                "User's friends document does not exist in the database");
          }
          List<dynamic> currentFriends =
              (freshSnap.data() as Map<String, dynamic>)['email'];
          if (currentFriends.contains(event.userEmail)) {
            throw Exception('This user is already your friend');
          }
          transaction.update(userFriendsRef, {
            'email': FieldValue.arrayUnion([event.userEmail]),
          });
        });
      }

      // 친구의 'friends' 문서 참조
      DocumentReference friendFriendsRef =
          _firestore.collection('friends').doc(event.userEmail);

      // 트랜잭션을 사용하여 상대방의 'friends' 문서 업데이트
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot friendSnapshot =
            await transaction.get(friendFriendsRef);

        if (!friendSnapshot.exists) {
          // 상대방의 'friends' 문서가 없다면 생성하고 사용자의 이메일 추가
          transaction.set(friendFriendsRef, {
            'email': [user.email],
          });
        } else {
          // 상대방의 'friends' 문서가 이미 있다면 사용자의 이메일 추가
          List<dynamic> friendEmails =
              (friendSnapshot.data() as Map<String, dynamic>)['email'];
          if (!friendEmails.contains(user.email)) {
            transaction.update(friendFriendsRef, {
              'email': FieldValue.arrayUnion([user.email]),
            });
          }
        }
      });

      emit(AddUserSuccess(event.userEmail));
      // Also trigger loading of updated contacts
      // add(LoadContacts());
    } catch (e) {
      emit(AddUserFailure(e.toString()));
    }
  }

  Future<void> _loadContacts(
      LoadContacts event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      var user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      DocumentSnapshot friendsSnapshot =
          await _firestore.collection('friends').doc('${user.email}').get();

      List<Map<String, dynamic>> loadedContacts = [];

      if (friendsSnapshot.exists) {
        Map<String, dynamic> data =
            friendsSnapshot.data() as Map<String, dynamic>;
        List<dynamic> friendsEmails =
            data['email']; // Assuming 'email' is a List.

        for (String friendEmail in friendsEmails) {
          DocumentSnapshot friendProfileDoc = await _firestore
              .collection('user_profile')
              .doc(friendEmail)
              .get();

          if (friendProfileDoc.exists) {
            Map<String, dynamic> friendData =
                friendProfileDoc.data() as Map<String, dynamic>;
            loadedContacts.add({
              'name': friendData['name'],
              'email': friendData['email'],
              'imageUrl': friendData['imageUrl'],
              'statusMessage': friendData['statusMessage'],
              'uid': friendData['uid'],
            });
          }
        }
      }

      allContacts = loadedContacts;
      emit(ContactsLoaded(contacts: allContacts));
    } catch (e) {
      emit(ContactsFailure(error: e.toString()));
    }
  }

  Future<void> _searchContacts(
      SearchContacts event, Emitter<ContactsState> emit) async {
    if (event.query.isEmpty) {
      emit(ContactsLoaded(contacts: allContacts));
    } else {
      final searchResults = allContacts.where((contact) {
        final nameLower = (contact['name'] as String? ?? '').toLowerCase();
        final queryLower = event.query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
      emit(ContactsSearchResults(searchResults: searchResults));
    }
  }
}
