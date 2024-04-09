// import 'package:flutter/material.dart';
// import 'package:chat_tunify/bloc/message_send_bloc.dart';
// import 'package:chat_tunify/bloc/chat_action_log_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class RecommendMessageWidget extends StatelessWidget {
//   final bool isRecommendMessageWidgetVisible;
//   final String recommandMessage;
//   final VoidCallback onClosePressed;
//   final Function(String, String, String, String, String)
//       onRecommandMessageCardTapped;
//   final String roomId;
//   final String myName;
//   final String myUid;
//   final String originalMessageContent;
//   final String sensibility;

//   const RecommendMessageWidget({
//     required this.isRecommendMessageWidgetVisible,
//     required this.recommandMessage,
//     required this.onClosePressed,
//     required this.onRecommandMessageCardTapped,
//     required this.roomId,
//     required this.myName,
//     required this.myUid,
//     required this.originalMessageContent,
//     required this.sensibility,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Visibility(
//       visible: isRecommendMessageWidgetVisible,
//       child: Container(
//         width: double.infinity,
//         color: Colors.lime[100],
//         child: Stack(
//           children: [
//             RecommandMessageCard(
//               recommandMessage: recommandMessage,
//               onTap: () {
//                 onRecommandMessageCardTapped(
//                   roomId,
//                   myName,
//                   myUid,
//                   originalMessageContent,
//                   sensibility,
//                 );
//               },
//             ),
//             Positioned(
//               right: 0,
//               child: IconButton(
//                 onPressed: onClosePressed,
//                 icon: const Icon(Icons.close),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RecommandMessageCard extends StatelessWidget {
//   final String recommandMessage;
//   final VoidCallback onTap;

//   const RecommandMessageCard({
//     required this.recommandMessage,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       child: Card(
//         margin: const EdgeInsets.fromLTRB(10, 10, 40, 10),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
//           child: Text(
//             recommandMessage,
//             style: const TextStyle(fontSize: 14),
//           ),
//         ),
//       ),
//       onTap: onTap,
//     );
//   }
// }
