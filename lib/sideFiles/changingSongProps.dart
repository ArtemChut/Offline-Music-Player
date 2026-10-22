import 'package:flutter/material.dart';


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


void changeAlbumCover(){

}
