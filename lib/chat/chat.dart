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
import 'package:chat_tunify/chat/mode_on_off_widget.dart';

class ChatRoomPage extends StatefulWidget {
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
  // Chat room variables
  late String roomId;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late ChatActionLogBloc _chatActionLogBloc;

  // Profile variables
  String? myName;
  String? myImageUrl;
  String? myUid;
  String? friendName;
  String? friendImageUrl = '';
  String? friendUid;

  // Chat message variables
  String? recommandMessage;
  String? firstMessageContent;
  String? sensibility;
  String? sendSensibility;
  final Map<String, bool> _originalMessageVisibility = {};
  bool _isRecommendMessageWidgetVisible = false;
  int _previousMessageCount = 0;
  String previousText = '';
  int backspaceCount = 0;
  int refreshMessageCount = 0;

  // Mode variables
  bool originalMessageCheckMode = false;
  bool isConvertMessageCheckMode = false;
  bool recommendMessageMode = true;

  // Other variables
  double keyboardHeight = 0;

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
    required String firstMessageContent,
    required String convertMessageContent,
    required bool isConvertMessage,
    required String originalSentiment,
    required String sendMessageSentiment,
  }) {
    context.read<MessageSendBloc>().add(FirebaseMessageSaveEvent(
          roomId: widget.roomId,
          senderEmail: FirebaseAuth.instance.currentUser!.email!,
          senderName: myName!,
          senderUID: myUid!,
          firstMessageContent: firstMessageContent,
          originalMessageContent: _textEditingController.text,
          convertMessageContent: convertMessageContent,
          timestamp: DateTime.now().toString(),
          isConvertMessage: isConvertMessage,
          originalSentiment: originalSentiment,
          sendMessageSentiment: sendMessageSentiment,
          backspaceCount: backspaceCount,
          refreshMessage: refreshMessageCount,
        ));

    //텍스트 필드 비우기
    _textEditingController.clear();
    setState(() {
      backspaceCount = 0;
      refreshMessageCount = 0;
    });
  }

  void _logChatAction(ChatAction action) {
    _chatActionLogBloc.add(ChatActionLogEvent(action, roomId, myName!));
  }

  @override
  void initState() {
    super.initState();

    roomId = widget.roomId;

    // 텍스트 컨트롤러 값 변경되면 스크롤을 아래로 내림
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

    _chatActionLogBloc = context.read<ChatActionLogBloc>();
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
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ModeOnOffWidget(
              originalMessageCheckMode: originalMessageCheckMode,
              isConvertMessageCheckMode: isConvertMessageCheckMode,
              recommendMessageMode: recommendMessageMode, // 추가
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
              onRecommendMessageModeChanged: (value) {
                // 추가
                setState(() {
                  recommendMessageMode = value;
                });
              });
        });
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
                  } else if (state.email == widget.email) {
                    // 상대방의 프로필 정보 로드됨
                    setState(() {
                      friendName = state.name;
                      friendImageUrl = state.imageUrl;
                      friendUid = state.uid;
                    });
                  }
                } else if (state is ProfileLoading) {}
              },
            ),
            BlocListener<MessageSendBloc, MessageSendState>(
                listener: (context, state) {
              if (state is AzureSentimentAnalysisSuccessState) {
                if (state.analysisResult == 'negative' &&
                    recommendMessageMode) {
                  sensibility = state.analysisResult;

                  //추천 메시지 ChatGPT Recommend Message Event
                  context.read<MessageSendBloc>().add(
                      ChatGptRecommendMessageEvent(
                          _textEditingController.text, roomId));
                } else {
                  //mixed, neutral, positive 일 때
                  saveMessageToFirebase(
                    firstMessageContent: '',
                    convertMessageContent: '',
                    isConvertMessage: false,
                    originalSentiment: state.analysisResult,
                    sendMessageSentiment: '',
                  );
                }
              }
              if (state is ChatGptRecommendMessageState) {
                setState(() {
                  recommandMessage = state.chatGptRecommendResponse;
                  _isRecommendMessageWidgetVisible = true;
                });
              }
              if (state is ChatGPTSendMessageSendErrorState) {}
            })
          ],
          child: totalWidet(),
        ));
  }

  Widget totalWidet() {
    return Column(
      children: [
        Expanded(child: BlocBuilder<MessageReceiveBloc, MessageReceiveState>(
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
        })),
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
                          Divider(height: 1, thickness: 1),
                          SizedBox(height: 25),
                        ],
                      ));
                }),
              ],
            )
          ],
        )),
      ],
    );
  }

  Widget messagingWidget(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        Message message = messages[index];
        return messageContainer(message, isSender: message.senderUID == myUid);
      },
    );
  }

  Widget messageContainer(Message message, {required bool isSender}) {
    String messageKey = '${message.senderUID}_${message.timestamp}';
    bool isOriginalVisible = _originalMessageVisibility[messageKey] ?? false;
    final bool isConvertMessage = message.isConvertMessage;

    return Column(children: [
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
                        ? const AssetImage(
                            'assets/images/default_profile_2.jpg')
                        : NetworkImage(friendImageUrl!) as ImageProvider),
              ),
              title: Row(children: [
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
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Visibility(
                        child: isConvertMessageCheckMode && isConvertMessage
                            ? const Icon(Icons.published_with_changes_rounded,
                                size: 20, color: Colors.blueAccent)
                            : const SizedBox(width: 5)),
                  ]),
                ),
              ]),
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
                          style: const TextStyle(
                              fontSize: 14, color: Colors.blue)),
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
                                if (_originalMessageVisibility[messageKey] ==
                                    true) {
                                  _logChatAction(
                                      ChatAction.viewOriginalMessage);
                                } else {
                                  _logChatAction(
                                      ChatAction.viewOriginalMessageClose);
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
                                      isOriginalVisible
                                          ? '원본 메시지 숨기기'
                                          : '원본 메시지 확인',
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  ]),
                            ),
                          ]),
                    ),
                  ]))),
      const Divider(height: 1, thickness: 1),
    ]);
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
                final currentText = _textEditingController.text;
                if (currentText.length < previousText.length) {
                  setState(() {
                    backspaceCount++;
                  });
                }
                previousText = currentText;
              },
            )),
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

                          setState(() {
                            //텍스트 컨트롤러에 있는 메시지를 임시저장
                            firstMessageContent = _textEditingController.text;
                          });

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
              child: BlocBuilder<MessageSendBloc, MessageSendState>(
                  builder: (context, state) {
                if (state is FirebaseMessageSaveSendingState) {
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
                      //recommandMessageWidget Toggle
                      setState(() {
                        _isRecommendMessageWidgetVisible = false;
                      });

                      // 감정분석 요청
                      context.read<MessageSendBloc>().add(
                          AzureSentimentAnalysisEvent2(
                              _textEditingController.text));

                      // 감정 분석 결과를 대기하고 결과를 얻음
                      final sentimentState = context
                          .read<MessageSendBloc>()
                          .stream
                          .firstWhere((state) =>
                              state is AzureSentimentAnalysisSuccessState2)
                          .then((state) =>
                              state as AzureSentimentAnalysisSuccessState2);

                      sentimentState.then((state) {
                        sendSensibility = state.analysisResult;

                        saveMessageToFirebase(
                          firstMessageContent: firstMessageContent!,
                          convertMessageContent: recommandMessage!,
                          isConvertMessage: false,
                          originalSentiment: sensibility!,
                          sendMessageSentiment: sendSensibility!,
                        );
                        _logChatAction(ChatAction.arrowUpward);
                      });
                    },
                    icon: const Icon(Icons.arrow_upward,
                        color: Colors.blueAccent),
                  );
                }
              }),
            ),
          ],
        ));
  }

  Widget recommendMessageWidget() {
    return Visibility(
        visible: _isRecommendMessageWidgetVisible,
        child: Container(
          width: double.infinity,
          color: Colors.lime[100],
          child: Stack(children: [
            recommandMessageCard(),
            Positioned(
              right: 0,
              child: Row(children: [
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
                      // 빈상자
                      return const SizedBox();
                    }
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isRecommendMessageWidgetVisible = false;
                      _logChatAction(ChatAction.recommendMessageCardClose);
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              ]),
            )
          ]),
        ));
  }

  Widget recommandMessageCard() {
    return Card(
        margin: const EdgeInsets.fromLTRB(10, 10, 100, 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                const TextSpan(
                    text: "예상되는 상대방의 감정: ",
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                  text: "$recommandMessage",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
