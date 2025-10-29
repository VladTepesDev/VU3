import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _ambientPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _isInitialized = false;

  bool get soundEnabled => _soundEnabled;

  Future<void> initialize() async {
    print('🎵 SoundService.initialize() called');
    if (_isInitialized) {
      print('🎵 Already initialized, skipping');
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      
      print('🎵 SoundService initialized, soundEnabled: $_soundEnabled');

      if (_soundEnabled) {
        await _startAmbientSound();
      }
      
      _isInitialized = true;
    } catch (e) {
      print('❌ Error initializing SoundService: $e');
    }
  }

  Future<void> _startAmbientSound() async {
    try {
      print('🎵 Starting ambient sound...');
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setVolume(0.3); // 30% volume for ambient
      await _ambientPlayer.play(AssetSource('sounds/ambient-sound.mp3'));
      print('🎵 Ambient sound started successfully');
    } catch (e) {
      print('❌ Error playing ambient sound: $e');
    }
  }

  Future<void> playTapSound() async {
    print('🔊 playTapSound called, soundEnabled: $_soundEnabled');
    if (!_soundEnabled) return;
    
    try {
      // Create a new player for each tap to allow overlapping sounds
      final player = AudioPlayer();
      await player.setVolume(0.5); // 50% volume for tap
      print('🔊 Playing tap sound...');
      await player.play(AssetSource('sounds/tap-sound.mp3'));
      
      // Dispose after playing
      player.onPlayerComplete.listen((_) {
        print('🔊 Tap sound completed');
        player.dispose();
      });
    } catch (e) {
      print('❌ Error playing tap sound: $e');
    }
  }

  Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);

    if (enabled) {
      await _startAmbientSound();
    } else {
      await _ambientPlayer.stop();
    }
  }

  Future<void> dispose() async {
    await _ambientPlayer.dispose();
  }
}
