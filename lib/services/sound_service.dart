import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _soundEnabled = true;
  bool _isInitialized = false;

  bool get soundEnabled => _soundEnabled;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing SoundService: \$e');
    }
  }

  Future<void> playTapSound() async {
    if (!_soundEnabled) return;
    
    try {
      final player = AudioPlayer();
      await player.setVolume(0.5);
      await player.play(AssetSource('sounds/tap-sound.mp3'));
      
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      print('Error playing tap sound: \$e');
    }
  }

  Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }
}
