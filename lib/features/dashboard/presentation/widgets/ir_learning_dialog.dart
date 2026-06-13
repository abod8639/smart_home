import 'dart:async';
import 'package:flutter/material.dart';

class IrLearningDialogContent extends StatefulWidget {
  const IrLearningDialogContent({super.key});

  @override
  State<IrLearningDialogContent> createState() => _IrLearningDialogContentState();
}

class _IrLearningDialogContentState extends State<IrLearningDialogContent> {
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _timer?.cancel();
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated circular countdown
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _countdown / 10.0,
                strokeWidth: 4,
                color: const Color(0xFF4C86FF),
                backgroundColor: Colors.white10,
              ),
              Text(
                '$_countdown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings_remote_rounded,
                color: Color(0xFF4C86FF), size: 20),
            const SizedBox(width: 8),
            Text(
              'جاري الاستماع للريموت',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Point the remote at the ESP32 sensor and press the desired button',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'It will close automatically after 10 seconds if no signal is received',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
