import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class TimerFeedback {
  TimerFeedback._();

  static final _player = AudioPlayer();

  static Future<void> alerta() async {
    HapticFeedback.heavyImpact();
    try {
      await _player.play(AssetSource('sounds/beep.wav'));
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}
