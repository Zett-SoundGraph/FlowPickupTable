import 'dart:async';

import 'package:flutter/material.dart';

class RealTimeClock extends StatefulWidget {
  const RealTimeClock({super.key});
  @override
  State<RealTimeClock> createState() => _RealTimeClockState();
}

class _RealTimeClockState extends State<RealTimeClock> {
  late Timer _timer;
  String _timeStr = "";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        _timeStr =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_timeStr,
        style: const TextStyle(
            color: Colors.yellowAccent,
            fontSize: 12,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold));
  }
}
