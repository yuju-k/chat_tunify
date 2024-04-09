// import 'package:flutter/material.dart';
// import 'package:chat_tunify/chat/message_class.dart';
// import 'package:chat_tunify/bloc/message_receive_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:chat_tunify/chat/widgets/messaging_container.dart';

// class MessagingWidget extends StatelessWidget {
//   final ScrollController scrollController;
//   final String myUid;
//   final String myImageUrl;
//   final String friendImageUrl;
//   final bool originalMessageCheckMode;
//   final bool isConvertMessageCheckMode;

//   const MessagingWidget({
//     super.key,
//     required this.scrollController,
//     required this.myUid,
//     required this.myImageUrl,
//     required this.friendImageUrl,
//     required this.originalMessageCheckMode,
//     required this.isConvertMessageCheckMode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<MessageReceiveBloc, MessageReceiveState>(
//       builder: (context, state) {
//         if (state is MessagesUpdated) {
//           return ListView.builder(
//             controller: scrollController,
//             itemCount: state.messages.length,
//             itemBuilder: (context, index) {
//               Message message = state.messages[index];
//               bool isSender = message.senderUID == myUid;
//               return MessageContainer(
//                 message: message,
//                 isSender: isSender,
//                 myImageUrl: myImageUrl,
//                 friendImageUrl: friendImageUrl,
//                 originalMessageCheckMode: originalMessageCheckMode,
//                 isConvertMessageCheckMode: isConvertMessageCheckMode,
//               );
//             },
//           );
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }
