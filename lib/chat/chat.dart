import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:chat_tunify/bloc/chat_bloc.dart';
import 'package:chat_tunify/bloc/message_send_bloc.dart';
import 'package:chat_tunify/bloc/profile_bloc.dart';
import 'package:chat_tunify/bloc/message_receive_bloc.dart';
import 'package:chat_tunify/bloc/chat_action_log_bloc.dart';
import 'package:chat_tunify/chat/message_class.dart';
import 'package:chat_tunify/chat/mode_on_off_widget.dart';

// 채팅방 화면을 나타내는 StatefulWidget
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
  late String roomId;
  final _textController = TextEditingController();
  final _textFocusNode = FocusNode();
  final _scrollController = ScrollController();
  late ChatActionLogBloc _actionLogBloc;

  String? myName;
  String? myImageUrl;
  String? myUid;
  String? friendName;
  String? friendImageUrl;
  String? friendUid;

  String? recommendedMessage;
  String? initialMessageContent;
  String? originalSentiment;
  String? sentSentiment;
  final Map<String, bool> _originalMessageVisibility = {};
  bool _isRecommendMessageVisible = false;
  int _previousMessageCount = 0;
  String _previousText = '';
  int _backspaceCount = 0;
  int _refreshMessageCount = 0;

  bool _showOriginalMessageMode = false;
  bool _showConvertedMessageMode = false;
  bool _recommendMessageMode = true;

  @override
  void initState() {
    super.initState();
    roomId = widget.roomId;
    _actionLogBloc = context.read<ChatActionLogBloc>();

    _textController.addListener(() {
      if (_textController.text.isNotEmpty) {
        setState(() => scrollToBottom());
      }
    });

    final profileBloc = context.read<ProfileBloc>();
    profileBloc.add(ProfileLoadRequested(widget.email));
    profileBloc
        .add(ProfileLoadRequested(FirebaseAuth.instance.currentUser!.email!));

    context.read<MessageReceiveBloc>().add(ListenForMessages(roomId: roomId));
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void scrollToBottomWithoutAnimation() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _saveMessageToFirebase({
    required String firstMessageContent,
    required String convertMessageContent,
    required bool isConvertMessage,
    required String originalSentiment,
    required String sendMessageSentiment,
  }) {
    context.read<MessageSendBloc>().add(FirebaseMessageSaveEvent(
          roomId: roomId,
          senderEmail: FirebaseAuth.instance.currentUser!.email!,
          senderName: myName!,
          senderUID: myUid!,
          firstMessageContent: firstMessageContent,
          originalMessageContent: _textController.text,
          convertMessageContent: convertMessageContent,
          timestamp: DateTime.now().toString(),
          isConvertMessage: isConvertMessage,
          originalSentiment: originalSentiment,
          sendMessageSentiment: sendMessageSentiment,
          backspaceCount: _backspaceCount,
          refreshMessage: _refreshMessageCount,
        ));

    _textController.clear();
    setState(() {
      _backspaceCount = 0;
      _refreshMessageCount = 0;
    });
  }

  void _logAction(ChatAction action) {
    _actionLogBloc.add(ChatActionLogEvent(action, roomId, myName!));
  }

  void _showModeSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ModeOnOffWidget(
        originalMessageCheckMode: _showOriginalMessageMode,
        isConvertMessageCheckMode: _showConvertedMessageMode,
        recommendMessageMode: _recommendMessageMode,
        onOriginalMessageCheckModeChanged: (value) {
          setState(() => _showOriginalMessageMode = value);
        },
        onConvertMessageCheckModeChanged: (value) {
          setState(() => _showConvertedMessageMode = value);
        },
        onRecommendMessageModeChanged: (value) {
          setState(() => _recommendMessageMode = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onLongPress: _showModeSettings,
          child: Text(widget.name),
        ),
        centerTitle: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatRoomBloc, ChatRoomState>(
            listener: (context, state) {
              if (state is ChatRoomLoaded) scrollToBottomWithoutAnimation();
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
                  setState(() {
                    myName = state.name;
                    myImageUrl = state.imageUrl;
                    myUid = state.uid;
                  });
                } else if (state.email == widget.email) {
                  setState(() {
                    friendName = state.name;
                    friendImageUrl = state.imageUrl;
                    friendUid = state.uid;
                  });
                }
              }
            },
          ),
          BlocListener<MessageSendBloc, MessageSendState>(
            listener: (context, state) {
              if (state is AzureSentimentAnalysisSuccessState) {
                if (state.analysisResult == 'negative' &&
                    _recommendMessageMode) {
                  originalSentiment = state.analysisResult;
                  context.read<MessageSendBloc>().add(LlmRecommendMessageEvent(
                        _textController.text,
                        roomId,
                      ));
                } else {
                  _saveMessageToFirebase(
                    firstMessageContent: '',
                    convertMessageContent: '',
                    isConvertMessage: false,
                    originalSentiment: state.analysisResult,
                    sendMessageSentiment: '',
                  );
                }
              }
              if (state is LlmMessageSentState) {
                setState(() {
                  recommendedMessage = state.response;
                  _isRecommendMessageVisible = true;
                });
              }
            },
          ),
        ],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(child: _buildMessageList()),
        _buildInputSection(),
      ],
    );
  }

  Widget _buildMessageList() {
    return BlocBuilder<MessageReceiveBloc, MessageReceiveState>(
      builder: (context, state) {
        if (state is MessagesUpdated) {
          if (_previousMessageCount != state.messages.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) scrollToBottom();
            });
            _previousMessageCount = state.messages.length;
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return _buildMessageTile(message,
                  isSender: message.senderUID == myUid);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMessageTile(Message message, {required bool isSender}) {
    final messageKey = '${message.senderUID}_${message.timestamp}';
    final isOriginalVisible = _originalMessageVisibility[messageKey] ?? false;
    final isConverted = message.isConvertMessage;

    return Column(
      children: [
        Container(
          color: isSender ? Colors.white : Colors.grey[100],
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: isSender
                  ? (myImageUrl?.isEmpty ?? true
                      ? const AssetImage('assets/images/default_profile.png')
                      : NetworkImage(myImageUrl!)) as ImageProvider
                  : (friendImageUrl?.isEmpty ?? true
                      ? const AssetImage('assets/images/default_profile_2.jpg')
                      : NetworkImage(friendImageUrl!)) as ImageProvider,
            ),
            title: Row(
              children: [
                Text(message.senderName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 5),
                Text(message.timestamp.substring(2, 16),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                if (_showConvertedMessageMode && isConverted)
                  const Icon(Icons.published_with_changes_rounded,
                      size: 20, color: Colors.blueAccent),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConverted
                      ? message.convertMessageContent
                      : message.originalMessageContent,
                  style: const TextStyle(fontSize: 14),
                ),
                if (isOriginalVisible && _showOriginalMessageMode)
                  Text(
                    message.originalMessageContent,
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                if (isConverted && _showOriginalMessageMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() =>
                              _originalMessageVisibility[messageKey] =
                                  !isOriginalVisible);
                          _logAction(isOriginalVisible
                              ? ChatAction.viewOriginalMessageClose
                              : ChatAction.viewOriginalMessage);
                        },
                        child: Row(
                          children: [
                            Icon(
                                isOriginalVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(isOriginalVisible ? '원본 메시지 숨기기' : '원본 메시지 확인',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildInputSection() {
    return Form(
      child: Stack(
        children: [
          Column(
            children: [
              _buildRecommendedMessage(),
              _buildTextInput(),
              KeyboardVisibilityBuilder(
                builder: (context, isKeyboardVisible) {
                  return Visibility(
                    visible: !isKeyboardVisible && !_isRecommendMessageVisible,
                    child: const Column(
                      children: [
                        Divider(height: 1, thickness: 1),
                        SizedBox(height: 25),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              focusNode: _textFocusNode,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요',
                border: UnderlineInputBorder(borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                if (value.length < _previousText.length) {
                  setState(() => _backspaceCount++);
                }
                _previousText = value;
              },
            ),
          ),
          if (!_isRecommendMessageVisible) _buildSendButton(),
          if (_isRecommendMessageVisible) _buildAcceptButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return BlocBuilder<MessageSendBloc, MessageSendState>(
      builder: (context, state) {
        if (state is MessageSendProcessingState) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircularProgressIndicator(),
          );
        }
        return IconButton(
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              context
                  .read<MessageSendBloc>()
                  .add(AzureSentimentAnalysisEvent(_textController.text));
              setState(() => initialMessageContent = _textController.text);
              _logAction(ChatAction.send);
            }
          },
          icon: const Icon(Icons.send),
        );
      },
    );
  }

  Widget _buildAcceptButton() {
    return BlocBuilder<MessageSendBloc, MessageSendState>(
      builder: (context, state) {
        if (state is MessageSendProcessingState) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return IconButton(
          onPressed: () async {
            setState(() => _isRecommendMessageVisible = false);
            context
                .read<MessageSendBloc>()
                .add(AzureSentimentAnalysisEvent(recommendedMessage!));
            final sentimentState = await context
                    .read<MessageSendBloc>()
                    .stream
                    .firstWhere(
                        (state) => state is AzureSentimentAnalysisSuccessState)
                as AzureSentimentAnalysisSuccessState;

            sentSentiment = sentimentState.analysisResult;
            _saveMessageToFirebase(
              firstMessageContent: initialMessageContent!,
              convertMessageContent: recommendedMessage!,
              isConvertMessage: true, // 추천 메시지를 수락했으므로 변환된 메시지로 처리
              originalSentiment: originalSentiment!,
              sendMessageSentiment: sentSentiment!,
            );
            _logAction(ChatAction.arrowUpward);
          },
          icon: const Icon(Icons.arrow_upward, color: Colors.blueAccent),
        );
      },
    );
  }

  Widget _buildRecommendedMessage() {
    return Visibility(
      visible: _isRecommendMessageVisible,
      child: Container(
        width: double.infinity,
        color: Colors.lime[100],
        child: Stack(
          children: [
            _buildRecommendationCard(),
            Positioned(
              right: 0,
              child: Row(
                children: [
                  BlocBuilder<MessageSendBloc, MessageSendState>(
                    builder: (context, state) {
                      if (state is MessageSendProcessingState) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _isRecommendMessageVisible = false);
                      _logAction(ChatAction.recommendMessageCardClose);
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

  Widget _buildRecommendationCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(10, 10, 100, 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: [
              const TextSpan(text: "추천 메시지: "),
              TextSpan(
                text: recommendedMessage ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
