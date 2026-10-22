import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:music_player/sideFiles/savingPrefs.dart';


Future<void> changeSongProps(String type, song, BuildContext context, void Function(VoidCallback) setState) async {
  final controller = TextEditingController();

  final String labelText = type == "name" ? "New song name" : "New artist name";

  final input = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("Change song's props"),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
            dialogContext,
            controller.text,
          ),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );

  controller.dispose();


  // actually chnaging song's properties
  if (input == null || input.trim().isEmpty) return;

  if (type == "name"){
    song.name = input;
  } else{
    song.artist = input;
  }



  setState(() {
    // UPADING THE UI
  },);
}


const allowed = [".svg", ".png", ".jpg"];
Future<void> changeAlbumCover(song, void Function(VoidCallback) setState) async {
  // allowing user to pick any image file
  final result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result == null) return;

  // finding out what format an image is in
  String filePath = result.paths[0]!;
  String fileExtension = "";
  while (!filePath.endsWith(".")){
    fileExtension += filePath[filePath.length-1];
    filePath = filePath.substring(0, filePath.length - 1);
  }
  fileExtension += ".";
  fileExtension = fileExtension.split('').reversed.join('');


  if (!allowed.contains(fileExtension)) return;


  song.alteredAlbumCoverPath = result.paths[0];
  await saveAllSongs();

  setState((){});
}
