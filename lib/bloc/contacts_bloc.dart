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
  List<Map<String, String>> allContacts = []; // 여기에 전체 연락처 목록을 저장

  ContactsBloc() : super(ContactsLoading()) {
    on<LoadContacts>((event, emit) {
      // 연락처 로드 로직 (여기에 더미 데이터 또는 API 호출 코드를 추가)
      // 예시를 위해 더미 데이터를 사용
      allContacts = [
        // 여기에 더미 연락처 데이터
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
    });

    on<SearchContacts>((event, emit) {
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
    });
  }
}
