import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/fpt_theme.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime endDate;
  final bool isCompact;

  const CountdownTimerWidget({
    super.key,
    required this.endDate,
    this.isCompact = false,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateRemaining();
        });
      }
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    if (now.isAfter(widget.endDate)) {
      _remaining = Duration.zero;
    } else {
      _remaining = widget.endDate.difference(now);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: FptColors.gray200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_off_outlined, size: 12, color: FptColors.gray600),
            SizedBox(width: 3),
            Text(
              'Đã đóng cược',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: FptColors.gray600,
              ),
            ),
          ],
        ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    final String text = days > 0
        ? '$days ngày ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final isUrgent = days == 0 && hours < 2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isUrgent ? FptColors.noRedBg : FptColors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isUrgent ? FptColors.noRed.withOpacity(0.3) : FptColors.orange.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 11,
            color: isUrgent ? FptColors.noRed : FptColors.orangeDark,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: widget.isCompact ? 10 : 11,
              fontWeight: FontWeight.w800,
              color: isUrgent ? FptColors.noRed : FptColors.orangeDark,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
