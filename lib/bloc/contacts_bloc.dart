import 'package:flutter_bloc/flutter_bloc.dart';

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
  final List<Map<String, String>> contacts;
  ContactsLoaded(this.contacts);
}

class ContactsSearchResults extends ContactsState {
  final List<Map<String, String>> searchResults;
  ContactsSearchResults(this.searchResults);
}

// Bloc
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  List<Map<String, String>> allContacts = [];

  ContactsBloc() : super(ContactsLoading()) {
    on<LoadContacts>((event, emit) => loadContacts(emit));
    on<SearchContacts>((event, emit) => searchContacts(event, emit));
  }

  void loadContacts(Emitter<ContactsState> emit) {
    // 연락처 로드 로직
    allContacts = [
      // 더미 연락처 데이터
      {
        'userId': 'chulsu',
        'userName': '김철수',
        'phone': '010-1234-5678',
        'email': 'chulsu@example.com',
        'image': 'https://picsum.photos/200/200?random=1',
      },
      {
        'userId': 'oppayam1004',
        'userName': '박건우',
        'phone': '010-1234-5678',
        'email': 'gunwoo@example.com',
        'image': 'https://picsum.photos/200/200?random=2',
      },
    ];
    emit(ContactsLoaded(allContacts));
  }

  void searchContacts(SearchContacts event, Emitter<ContactsState> emit) {
    if (event.query.isEmpty) {
      emit(ContactsLoaded(allContacts));
    } else {
      final searchResults = allContacts.where((contact) {
        final nameLower = contact['userName']!.toLowerCase();
        final queryLower = event.query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
      emit(ContactsSearchResults(searchResults));
    }
  }
}
