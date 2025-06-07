# ChatTunify
감정 분석과 메시지 추천 기능을 제공하는 실시간 채팅 애플리케이션입니다.

## 📱 주요 기능
### 🎯 핵심 기능
- **실시간 채팅**: Firebase Realtime Database를 활용한 실시간 메시징
- **감정 분석**: Azure Cognitive Services를 통한 메시지 감정 분석
- **메시지 추천**: ChatGPT API를 활용한 상황별 메시지 추천
- **사용자 행동 로깅**: 채팅 내 사용자 행동 패턴 분석

### 💬 채팅 기능
- 1:1 실시간 채팅
- 메시지 전송/수신
- 원본 메시지 및 변환된 메시지 확인
- 메시지 감정 상태 표시

### 👥 연락처 관리
- 친구 추가/검색
- 프로필 이미지 및 상태 메시지 설정
- 채팅방 자동 생성

### 📊 연구 기능
- 백스페이스 사용 횟수 추적
- 메시지 새로고침 횟수 기록
- 다양한 사용자 액션 로깅
- 감정 분석 결과 저장

## 🛠 기술 스택

### Frontend
- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **BLoC Pattern**: 상태 관리
- **Material Design 3**: UI/UX 디자인

### Backend & Database
- **Firebase Authentication**: 사용자 인증
- **Firebase Realtime Database**: 실시간 메시징
- **Cloud Firestore**: 사용자 프로필 및 친구 관계 관리
- **Firebase Storage**: 프로필 이미지 저장

### AI & API 서비스
- **Azure Cognitive Services**: 텍스트 감정 분석
- **OpenAI GPT-4**: 메시지 추천 및 감정 예측
- **HTTP 클라이언트**: RESTful API 통신

### 개발 도구
- **flutter_bloc**: 상태 관리 라이브러리
- **image_picker**: 이미지 선택 기능
- **flutter_dotenv**: 환경 변수 관리

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK (>=3.2.0)
- Dart SDK
- Firebase 프로젝트 설정
- Azure Cognitive Services API 키
- OpenAI API 키

### 설치 및 설정

1. **저장소 클론**
```bash
git clone https://github.com/your-username/chat_tunify.git
cd chat_tunify
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **환경 변수 설정**
프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가:
```env
AZURE_API_KEY=your_azure_api_key
AZURE_END_POINT=your_azure_endpoint
AZURE_SENTIMENT_PATH=/text/analytics/v3.1/sentiment
OPENAI_API_KEY=your_openai_api_key
OPENAI_END_POINT=https://api.openai.com/v1/chat/completions
```

4. **Firebase 설정**
- Firebase 콘솔에서 프로젝트 생성
- `firebase_options.dart` 파일의 설정값 업데이트
- Authentication, Realtime Database, Firestore, Storage 활성화

5. **앱 실행**
```bash
flutter run
```

## 📁 프로젝트 구조

```
lib/
├── auth/                    # 인증 관련 페이지
│   ├── create.dart         # 회원가입
│   ├── login.dart          # 로그인
│   └── create_profile.dart # 프로필 생성
├── bloc/                   # BLoC 상태 관리
│   ├── auth_bloc.dart      # 인증 상태 관리
│   ├── chat_bloc.dart      # 채팅방 관리
│   ├── message_send_bloc.dart    # 메시지 전송
│   ├── message_receive_bloc.dart # 메시지 수신
│   ├── contacts_bloc.dart  # 연락처 관리
│   ├── profile_bloc.dart   # 프로필 관리
│   └── chat_action_log_bloc.dart # 사용자 행동 로깅
├── chat/                   # 채팅 관련 기능
│   ├── chat.dart          # 채팅 화면
│   ├── chat_list.dart     # 채팅 목록
│   ├── message_class.dart # 메시지 모델
│   └── mode_on_off_widget.dart # 기능 설정
├── contacts/               # 연락처 관리
│   ├── contacts.dart      # 연락처 목록
│   └── add_friend.dart    # 친구 추가
├── settings/               # 설정 및 프로필
│   ├── settings.dart      # 설정 메인
│   ├── profile_component.dart # 프로필 컴포넌트
│   └── edit_profile.dart  # 프로필 편집
├── llm_api_service.dart   # AI API 서비스
├── firebase_options.dart  # Firebase 설정
└── main.dart             # 앱 진입점
```

## 🔧 주요 구성 요소

### BLoC 패턴 구현
- **AuthenticationBloc**: 로그인/로그아웃 상태 관리
- **ChatRoomBloc**: 채팅방 생성 및 관리
- **MessageSendBloc**: 메시지 전송 및 AI 분석
- **MessageReceiveBloc**: 실시간 메시지 수신
- **ChatActionLogBloc**: 사용자 행동 데이터 수집

### AI 통합
- **감정 분석**: 사용자가 입력한 메시지의 감정 상태 분석
- **메시지 추천**: 부정적 감정 감지 시 대안 메시지 제안
- **대화 맥락 분석**: 이전 대화 내용을 고려한 상황별 추천

## 📊 연구 데이터 수집

이 앱은 HCI 연구 목적으로 다음 데이터를 수집합니다:
- 메시지 작성 중 백스페이스 사용 패턴
- 추천 메시지 수용/거부 빈도
- 감정 분석 결과와 실제 전송 메시지 비교
- 사용자 인터페이스 상호작용 로그

## 🎨 UI/UX 특징

- **Material Design 3** 적용
- **다크/라이트 테마** 지원
- **반응형 디자인** (키보드 표시 시 레이아웃 조정)
- **직관적인 네비게이션** (하단 탭 바)
- **접근성 고려** (적절한 색상 대비, 의미론적 마크업)

## 🔒 개인정보 보호

- Firebase Authentication을 통한 안전한 사용자 인증
- 모든 메시지는 암호화되어 저장
- 연구 데이터는 익명화되어 처리
- 사용자 동의 하에 데이터 수집

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 연구 목적으로 개발되었습니다. 상업적 이용 시 별도 문의 바랍니다.

## 📞 연락처

프로젝트 관련 문의: [your-email@example.com]

---

**Note**: 이 앱은 HCI(Human-Computer Interaction) 연구 목적으로 개발되었으며, 사용자의 채팅 패턴과 AI 추천 시스템의 효과를 분석하기 위해 설계되었습니다.
