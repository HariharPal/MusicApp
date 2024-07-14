import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuidoWave extends StatefulWidget {
  final String path;
  const AuidoWave({super.key, required this.path});

  @override
  State<AuidoWave> createState() => _AuidoWaveState();
}

class _AuidoWaveState extends State<AuidoWave> {
  final PlayerController playerController = PlayerController();
  @override
  void initState() {
    playerController.preparePlayer(path: widget.path);
    super.initState();
  }

  void initAudioPlayer() async {
    await playerController.preparePlayer(path: widget.path);
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  Future<void> playAndPause() async {
    if (!playerController.playerState.isPlaying) {
      await playerController.startPlayer(finishMode: FinishMode.stop);
    } else if (!playerController.playerState.isPaused) {
      await playerController.pausePlayer();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: playAndPause,
            icon: Icon(!playerController.playerState.isPlaying
                ? CupertinoIcons.play_arrow_solid
                : CupertinoIcons.pause_solid)),
        Expanded(
          child: AudioFileWaveforms(
            size: const Size(double.infinity, 100),
            playerController: playerController,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: Pallete.borderColor,
              liveWaveColor: Pallete.gradient2,
              spacing: 6,
              showSeekLine: false,
            ),
          ),
        ),
      ],
    );
  }
}
