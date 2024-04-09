import 'package:flutter/material.dart';

class ModeOnOffWidget extends StatefulWidget {
  final bool originalMessageCheckMode;
  final bool isConvertMessageCheckMode;
  final Function(bool) onOriginalMessageCheckModeChanged;
  final Function(bool) onConvertMessageCheckModeChanged;

  const ModeOnOffWidget({
    super.key,
    required this.originalMessageCheckMode,
    required this.isConvertMessageCheckMode,
    required this.onOriginalMessageCheckModeChanged,
    required this.onConvertMessageCheckModeChanged,
  });

  @override
  ModeOnOffWidgetState createState() => ModeOnOffWidgetState();
}

class ModeOnOffWidgetState extends State<ModeOnOffWidget> {
  late bool _originalMessageCheckMode;
  late bool _isConvertMessageCheckMode;

  @override
  void initState() {
    super.initState();
    _originalMessageCheckMode = widget.originalMessageCheckMode;
    _isConvertMessageCheckMode = widget.isConvertMessageCheckMode;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('원본 메시지 확인'),
                Switch(
                  value: _originalMessageCheckMode,
                  onChanged: (value) {
                    setModalState(() {
                      _originalMessageCheckMode = value;
                    });
                    // You can still call the main setState if you need to update the main page
                    setState(() {});
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('변환된 메시지 확인'),
                Switch(
                  value: _isConvertMessageCheckMode,
                  onChanged: (value) {
                    setModalState(() {
                      _isConvertMessageCheckMode = value;
                    });
                    // Same here for the main page update if necessary
                    setState(() {});
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
