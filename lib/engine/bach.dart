import 'package:just_audio/just_audio.dart';

/// класс для унификации работы со звуком
class Bach {
  bool musicEnableFlag = true;
  bool fxEnableFlag = true;
  double musicVolume = 1;
  double fxVolume = 1;
  AudioPlayer bgm = AudioPlayer();
  Map<String, AudioPlayer> slots = {};

  void pauseBgm() {
    bgm.pause();
  }

  void setMusicVolume(double vol) {
    musicVolume = vol;
    if (musicVolume < 0.01) {
      musicVolume = 0;
      musicEnableFlag = false;
    }
    musicEnableFlag = true;
    bgm.setVolume(musicVolume);
  }

  void setFxVolume(double vol) {
    fxVolume = vol;
    if (fxVolume < 0.01) {
      fxVolume = 0;
      fxEnableFlag = false;
    }
    fxEnableFlag = true;
    slots.forEach((key, value) {
      value.setVolume(fxVolume);
    });
  }

  void resumeBgm() {
    if (!musicEnableFlag) return;
    bgm.play();
  }

  void playBgm(String name) {
    if (!musicEnableFlag) return;
    stopBgm();
    bgm
      ..setLoopMode(LoopMode.one)
      ..setAsset('assets/audio/$name')
      ..setVolume(musicVolume)
      ..play();
  }

  void playFX(String name) {
    if (!fxEnableFlag) return;
    if (slots.entries.where((element) => element.key == name).isNotEmpty) {
      //if (slots.entries.where((element) => element.key == name).single.value.
      if (slots.entries
          .where((element) => element.key == name)
          .single
          .value
          .playing) {
        slots.entries
            .where((element) => element.key == name)
            .single
            .value
            .seek(Duration.zero);
      }
      slots.entries.where((element) => element.key == name).first.value
        ..setVolume(fxVolume)
        ..play();
      return;
    }
    slots.addAll({
      name: AudioPlayer()
        ..setAsset('assets/audio/$name')
        ..setVolume(fxVolume)
        ..play()
    });
  }

  void stopBgm() => bgm.stop();
}
