// import 'package:flutter/material.dart';
// import 'package:chat_tunify/chat/message_class.dart';
// import 'package:chat_tunify/bloc/chat_action_log_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class MessageContainer extends StatelessWidget {
//   final Message message;
//   final bool isSender;
//   final String myImageUrl;
//   final String friendImageUrl;
//   final bool originalMessageCheckMode;
//   final bool isConvertMessageCheckMode;

//   const MessageContainer({
//     required this.message,
//     required this.isSender,
//     required this.myImageUrl,
//     required this.friendImageUrl,
//     required this.originalMessageCheckMode,
//     required this.isConvertMessageCheckMode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String messageKey = '${message.senderUID}_${message.timestamp}';
//     bool isOriginalVisible = _originalMessageVisibility[messageKey] ?? false;
//     final bool isConvertMessage = message.isConvertMessage;

//     return Column(
//       children: [
//         Container(
//           color: isSender ? Colors.white : Colors.grey[100],
//           child: ListTile(
//             leading: CircleAvatar(
//               radius: 20,
//               backgroundImage: isSender
//                   ? (myImageUrl == ''
//                       ? const AssetImage('assets/images/default_profile.png')
//                       : NetworkImage(myImageUrl) as ImageProvider)
//                   : (friendImageUrl == ''
//                       ? const AssetImage('assets/images/default_profile_2.jpg')
//                       : NetworkImage(friendImageUrl) as ImageProvider),
//             ),
//             title: Row(
//               children: [
//                 Text(
//                   message.senderName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(width: 5),
//                 Text(
//                   //timestamp값은 24-01-10 19:50 까지만 표시
//                   message.timestamp.substring(2, 16),
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 const SizedBox(width: 5),
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Visibility(
//                           child: isConvertMessageCheckMode && isConvertMessage
//                               ? const Icon(Icons.published_with_changes_rounded,
//                                   size: 20, color: Colors.blueAccent)
//                               : const SizedBox(width: 5)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isConvertMessage
//                       ? message.convertMessageContent
//                       : message.originalMessageContent,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 Visibility(
//                   visible: isOriginalVisible && originalMessageCheckMode,
//                   child: Text(message.originalMessageContent,
//                       style: const TextStyle(fontSize: 14, color: Colors.blue)),
//                 ),
//                 Visibility(
//                   visible: isConvertMessage && originalMessageCheckMode,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           setState(() {
//                             _originalMessageVisibility[messageKey] =
//                                 !isOriginalVisible;
//                           });
//                           if (_originalMessageVisibility[messageKey] == true) {
//                             //원본메시지 확인버튼 클릭시 로그 기록
//                             context.read<ChatActionLogBloc>().add(
//                                 ChatActionLogEvent(
//                                     ChatAction.viewOriginalMessage,
//                                     roomId,
//                                     myName));
//                           } else {
//                             //원본메시지 숨기기 버튼 클릭시 로그 기록
//                             context.read<ChatActionLogBloc>().add(
//                                 ChatActionLogEvent(
//                                     ChatAction.viewOriginalMessageClose,
//                                     roomId,
//                                     myName));
//                           }
//                         },
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Icon(
//                                 !isOriginalVisible
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                                 size: 20,
//                                 color: Colors.grey),
//                             const SizedBox(width: 5),
//                             Text(
//                               isOriginalVisible ? '원본 메시지 숨기기' : '원본 메시지 확인',
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const Divider(height: 1, thickness: 1),
//       ],
//     );
//   }
// }
