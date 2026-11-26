import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'songInteraction.dart';

import '../SongsCataloguePage.dart';

bool changed = false;

// CHECKING IF SONG HAS COME TO AN END
StreamBuilder checkSongEnded(void Function(VoidCallback) setState, scrollController) {
  return // CHECKING IF SONG HAS COME TO AN END
    StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {

        final playerState = snapshot.data;

        if (playerState != null &&
            playerState.processingState == ProcessingState.completed &&
            !changed) {

          changed = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            prevNextSong("next", setState, scrollController);
          });
        }

        return const SizedBox();
      },
    );
}