import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  AudioPlayer? audioPlayer;
  late HomeLocalRepository _homeLocalRepository;
  bool isPlaying = false;
  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  void updateSong(SongModel song) async {
    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();
    //Adding Audiosource to url;
    final audioSource = AudioSource.uri(Uri.parse(song.song_url),
        tag: MediaItem(
            id: song.id,
            title: song.song_name,
            artist: song.artist,
            artUri: Uri.parse(song.thumbnail_url)));
    //setting audio to audioSource so audio must play;
    await audioPlayer!.setAudioSource(audioSource);
    //Listneing to the state of music audioPlayer whereas
    audioPlayer!.playerStateStream.listen((state) {
      //If state is complete or Processing state is complete then we says seek duration to zero, pause the audioplayer and isplaying false so proceed to set state change.
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;
        this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
      }
    });
    _homeLocalRepository.uploadLocalSong(song);

    //audioPlayer let play and let playing to and state to song;
    audioPlayer!.play();
    isPlaying = true;
    state = song;
  }

  void playPause() {
    //when user play or pause checking the isPlaying condition and respectively pausing and playing the audioplayer;
    if (isPlaying) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void seek(double val) {
    audioPlayer!.seek(
      Duration(
        milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt(),
      ),
    );
  }
}
