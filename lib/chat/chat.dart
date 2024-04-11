import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:chat_tunify/bloc/chat_bloc.dart';
import 'package:chat_tunify/bloc/message_send_bloc.dart';
import 'package:chat_tunify/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_tunify/chat/message_class.dart';
import 'package:chat_tunify/bloc/message_receive_bloc.dart';
import 'package:chat_tunify/bloc/chat_action_log_bloc.dart';
import 'package:chat_tunify/chat/widgets/mode_on_off_widget.dart';

class ChatRoomPage extends StatefulWidget {
  //const ChatRoomPage({super.key});
  final String email;
  final String name;
  final String uid;
  final String roomId;

  const ChatRoomPage({
    super.key,
    required this.name,
    required this.email,
    required this.uid,
    required this.roomId,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late String roomId;

  //나의 프로필 정보를 저장할 변수
  String? myName;
  String? myImageUrl;
  String? myUid;

  //친구 프로필 정보를 저장할 변수
  String? friendName;
  String? friendImageUrl = '';
  String? friendUid;

  String? recommandMessage; // 추천 메시지 내용을 위한 변수
  String? sensibility; // 메시지의 감성 분석 결과를 담을 변수

  final Map<String, bool> _originalMessageVisibility = {};
  bool _isRecommendMessageWidgetVisible = false;

  int _previousMessageCount = 0; // 메시지 목록의 이전 길이를 저장하는 변수

  //** 모드 관련 변수 실험군에 맞춰서 변경 **//
  bool originalMessageCheckMode = false; //원본 메시지확인 버튼 활성화 모드
  bool isConvertMessageCheckMode = false; //변환된 메시지인지 확인할 수 있는 모드
  //** */

  double keyboardHeight = 0;

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();
  //스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();
  int backspaceCount = 0; // Counter for backspace key presses

  //스크롤러 맨 아래로 내리는 함수
  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  //스크롤러 맨 아래로 내리기, 애니메이션 없이
  void scrollToBottomWithoutAnimation() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void saveMessageToFirebase({
    required String convertMessageContent,
    required bool isConvertMessage,
    required String originalSentiment,
    required String sendMessageSentiment,
    required int backspaceCount,
  }) {
    context.read<MessageSendBloc>().add(FirebaseMessageSaveEvent(
          roomId: widget.roomId,
          senderEmail: FirebaseAuth.instance.currentUser!.email!,
          senderName: myName!,
          senderUID: myUid!,
          originalMessageContent: _textEditingController.text,
          convertMessageContent: convertMessageContent,
          timestamp: DateTime.now().toString(),
          isConvertMessage: isConvertMessage,
          originalSentiment: originalSentiment,
          sendMessageSentiment: sendMessageSentiment,
          backspaceCount: backspaceCount,
        ));

    //텍스트 필드 비우기
    _textEditingController.clear();
  }

  @override
  void initState() {
    super.initState();

    roomId = widget.roomId;

    // 텍스트 컨트롤러 값 변경되면 _isRecommendMessageWidgetVisible를 false로 변경
    _textEditingController.addListener(() {
      if (_textEditingController.text.isNotEmpty) {
        setState(() {
          scrollToBottom();
        });
      }
    });

    // profile_bloc을 이용해서 나와 상대방의 프로필을 불러옴
    final profileBloc = context.read<ProfileBloc>();
    profileBloc.add(ProfileLoadRequested(widget.email)); // 상대방 프로필
    profileBloc.add(ProfileLoadRequested(
        FirebaseAuth.instance.currentUser!.email!)); // 나의 프로필

    // Realtime Database에서 채팅방 정보 불러오기
    context.read<MessageReceiveBloc>().add(ListenForMessages(roomId: roomId));
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    textFieldFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showModalBottomSheet() {
    //modeOnOffWidget을 모달로 띄우는 함수
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ModeOnOffWidget(
          originalMessageCheckMode: originalMessageCheckMode,
          isConvertMessageCheckMode: isConvertMessageCheckMode,
          onOriginalMessageCheckModeChanged: (value) {
            setState(() {
              originalMessageCheckMode = value;
            });
          },
          onConvertMessageCheckModeChanged: (value) {
            setState(() {
              isConvertMessageCheckMode = value;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onLongPress: () {
            _showModalBottomSheet();
          },
          child: Text(widget.name),
        ),
        centerTitle: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatRoomBloc, ChatRoomState>(
            listener: (context, state) {
              if (state is ChatRoomLoaded) {
                scrollToBottomWithoutAnimation();
              }
              if (state is ChatRoomCreated) {
                //print('Chat room created with ID: ${state.roomId}');
                context
                    .read<MessageReceiveBloc>()
                    .add(ListenForMessages(roomId: roomId));
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded) {
                if (state.email == FirebaseAuth.instance.currentUser!.email) {
                  // 나의 프로필 정보 로드됨
                  setState(() {
                    myName = state.name;
                    myImageUrl = state.imageUrl;
                    myUid = state.uid;
                  });
                  //print('My name: $myName / $myUid');
                } else if (state.email == widget.email) {
                  // 상대방의 프로필 정보 로드됨
                  setState(() {
                    friendName = state.name;
                    friendImageUrl = state.imageUrl;
                    friendUid = state.uid;
                  });
                  //print('Friend name: $friendName / $friendUid');
                }
              } else if (state is ProfileLoading) {
                // print('Loading profile...');
              }
            },
          ),
          BlocListener<MessageSendBloc, MessageSendState>(
            listener: (context, state) {
              if (state is AzureSentimentAnalysisSuccessState) {
                if (state.analysisResult == 'negative') {
                  sensibility = state.analysisResult;

                  //추천 메시지 ChatGPT Recommend Message Event
                  context.read<MessageSendBloc>().add(
                      ChatGptRecommendMessageEvent(
                          _textEditingController.text));
                } else {
                  //mixed, neutral, positive 일 때
                  saveMessageToFirebase(
                    convertMessageContent: '',
                    isConvertMessage: false,
                    originalSentiment: state.analysisResult,
                    sendMessageSentiment: '',
                    backspaceCount: backspaceCount,
                  );
                }
              }
              if (state is ChatGptRecommendMessageState) {
                //print('GPT 추천 메시지: ${state.chatGptRecommendResponse}');
                setState(() {
                  recommandMessage = state.chatGptRecommendResponse;
                  _isRecommendMessageWidgetVisible = true;
                });
              }
              if (state is ChatGPTSendMessageSendErrorState) {
                // Handle the error
                //print('Error: ${state.error}');
              }
            },
          ),
        ],
        child: totalWidet(),
      ),
    );
  }

  Widget totalWidet() {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<MessageReceiveBloc, MessageReceiveState>(
            builder: (context, state) {
              if (state is MessagesUpdated) {
                if (_previousMessageCount != state.messages.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      scrollToBottom();
                    }
                  });
                  _previousMessageCount = state.messages.length;
                }

                return messagingWidget(state.messages);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Form(
          child: Stack(
            children: [
              Column(
                children: [
                  recommendMessageWidget(),
                  typingMessageWidget(),
                  KeyboardVisibilityBuilder(
                      builder: (context, isKeyboardVisible) {
                    return Visibility(
                      visible: !isKeyboardVisible &&
                          !_isRecommendMessageWidgetVisible,
                      child: const Column(
                        children: [
                          Divider(
                            height: 1,
                            thickness: 1,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget messagingWidget(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        Message message = messages[index];
        bool isSender = message.senderUID == myUid;
        return messageContainer(message, isSender: isSender);
      },
    );
  }

  Widget messageContainer(Message message, {required bool isSender}) {
    String messageKey = '${message.senderUID}_${message.timestamp}';
    bool isOriginalVisible = _originalMessageVisibility[messageKey] ?? false;
    final bool isConvertMessage = message.isConvertMessage;

    return Column(
      children: [
        Container(
          color: isSender ? Colors.white : Colors.grey[100],
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: isSender
                  ? (myImageUrl == ''
                      ? const AssetImage('assets/images/default_profile.png')
                      : NetworkImage(myImageUrl!) as ImageProvider)
                  : (friendImageUrl == ''
                      ? const AssetImage('assets/images/default_profile_2.jpg')
                      : NetworkImage(friendImageUrl!) as ImageProvider),
            ),
            title: Row(
              children: [
                Text(
                  message.senderName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  //timestamp값은 24-01-10 19:50 까지만 표시
                  message.timestamp.substring(2, 16),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                          child: isConvertMessageCheckMode && isConvertMessage
                              ? const Icon(Icons.published_with_changes_rounded,
                                  size: 20, color: Colors.blueAccent)
                              : const SizedBox(width: 5)),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConvertMessage
                      ? message.convertMessageContent
                      : message.originalMessageContent,
                  style: const TextStyle(fontSize: 14),
                ),
                Visibility(
                  visible: isOriginalVisible && originalMessageCheckMode,
                  child: Text(message.originalMessageContent,
                      style: const TextStyle(fontSize: 14, color: Colors.blue)),
                ),
                Visibility(
                  visible: isConvertMessage && originalMessageCheckMode,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _originalMessageVisibility[messageKey] =
                                !isOriginalVisible;
                          });
                          if (_originalMessageVisibility[messageKey] == true) {
                            //원본메시지 확인버튼 클릭시 로그 기록
                            context.read<ChatActionLogBloc>().add(
                                ChatActionLogEvent(
                                    ChatAction.viewOriginalMessage,
                                    roomId,
                                    myName!));
                          } else {
                            //원본메시지 숨기기 버튼 클릭시 로그 기록
                            context.read<ChatActionLogBloc>().add(
                                ChatActionLogEvent(
                                    ChatAction.viewOriginalMessageClose,
                                    roomId,
                                    myName!));
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                                !isOriginalVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20,
                                color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              isOriginalVisible ? '원본 메시지 숨기기' : '원본 메시지 확인',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Widget typingMessageWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _textEditingController,
              focusNode: textFieldFocusNode, // Attach the focus node here
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요',
                border: UnderlineInputBorder(borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                int count = _textEditingController.value.text.runes.length;
                if (value.length < count) {
                  backspaceCount++;
                }
              },
            ),
          ),
          BlocBuilder<MessageSendBloc, MessageSendState>(
            builder: (context, state) {
              if (state is ChatGPTSendMessageSendingState &&
                  !_isRecommendMessageWidgetVisible) {
                // Show loading indicator when message is being sent
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CircularProgressIndicator(),
                );
              } else {
                // Show send button when not sending a message
                return Visibility(
                  visible: !_isRecommendMessageWidgetVisible,
                  child: IconButton(
                    onPressed: () {
                      // Only allow message send if text field has content
                      if (_textEditingController.text.isNotEmpty) {
                        context.read<MessageSendBloc>().add(
                            AzureSentimentAnalysisEvent(
                                _textEditingController.text));

                        //메시지 전송 로그 기록
                        context.read<ChatActionLogBloc>().add(
                            ChatActionLogEvent(
                                ChatAction.send, roomId, myName!));
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                );
              }
            },
          ),
          Visibility(
            visible: _isRecommendMessageWidgetVisible,
            child: IconButton(
              onPressed: () {
                //recommandMessageWidget Toggle
                setState(() {
                  _isRecommendMessageWidgetVisible = false;
                });

                saveMessageToFirebase(
                  convertMessageContent: recommandMessage!,
                  isConvertMessage: false,
                  originalSentiment: sensibility!,
                  sendMessageSentiment: '',
                  backspaceCount: backspaceCount,
                );

                //추천메시지 상태에서 메시지 전송 로그 기록
                context.read<ChatActionLogBloc>().add(ChatActionLogEvent(
                    ChatAction.arrowUpward, roomId, myName!));
              },
              icon: const Icon(Icons.arrow_upward, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget recommendMessageWidget() {
    return Visibility(
      visible: _isRecommendMessageWidgetVisible,
      child: Container(
        width: double.infinity,
        color: Colors.lime[100],
        child: Stack(
          children: [
            recommandMessageCard(),
            // Close button
            Positioned(
              right: 0,
              child: Row(
                children: [
                  BlocBuilder<MessageSendBloc, MessageSendState>(
                    builder: (context, state) {
                      if (state is ChatGPTSendMessageSendingState) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      } else {
                        return IconButton(
                          onPressed: () {
                            if (_textEditingController.text.isNotEmpty) {
                              context.read<MessageSendBloc>().add(
                                  ChatGptRecommendMessageEvent(
                                      _textEditingController.text));
                              //새로고침 로그 기록
                              context.read<ChatActionLogBloc>().add(
                                  ChatActionLogEvent(
                                      ChatAction.refresh, roomId, myName!));
                            }
                          },
                          icon: const Icon(Icons.refresh,
                              color: Colors.blueAccent),
                        );
                      }
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isRecommendMessageWidgetVisible = false;
                        // 로그 기록 (추천 메시지 창 닫은 경우)
                        context
                            .read<ChatActionLogBloc>()
                            .add(ChatActionLogEvent(
                              ChatAction.recommendMessageCardClose,
                              roomId,
                              myName!,
                            ));
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recommandMessageCard() {
    return InkWell(
      child: Card(
        margin: const EdgeInsets.fromLTRB(10, 10, 40, 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
          child: Text(
            recommandMessage ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _isRecommendMessageWidgetVisible = false;
          //Firebase에 메시지 저장
          context.read<MessageSendBloc>().add(FirebaseMessageSaveEvent(
                roomId: roomId,
                senderEmail: FirebaseAuth.instance.currentUser!.email!,
                senderName: myName!,
                senderUID: myUid!,
                originalMessageContent: _textEditingController.text,
                convertMessageContent: recommandMessage!,
                timestamp: DateTime.now().toString(),
                isConvertMessage: true,
                originalSentiment:
                    sensibility ?? '', // sensibility가 null이면 빈 문자열로 설정
                sendMessageSentiment:
                    sensibility ?? '', // sensibility가 null이면 빈 문자열로 설정
                backspaceCount: backspaceCount,
              ));

          saveMessageToFirebase(
            convertMessageContent: recommandMessage!,
            isConvertMessage: true,
            originalSentiment: sensibility ?? '',
            sendMessageSentiment: sensibility ?? '',
            backspaceCount: backspaceCount,
          );

          //추천메시지 카드 클릭시 로그 기록
          context.read<ChatActionLogBloc>().add(ChatActionLogEvent(
              ChatAction.recommandMessageCard, roomId, myName!));
        });
      },
    );
  }
}
