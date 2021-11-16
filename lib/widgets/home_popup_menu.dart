import 'package:Musify/databases/songs_adapter.dart';
import 'package:Musify/widgets/add_to_playlist.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class homepopup extends StatefulWidget {
  const homepopup({Key? key, required this.audioId}) : super(key: key);
  final String audioId;
  @override
  _homepopupState createState() => _homepopupState();
}

class _homepopupState extends State<homepopup> {
  @override
  Widget build(BuildContext context) {
    Box box = Hive.box("songs");
    List<dynamic> favorites = box.get("favorites");
    List<Songs> song = box.get("tracks");
    final temp = song.firstWhere(
      (element) => element.id.toString().contains(widget.audioId),
    );

    return PopupMenuButton(
      itemBuilder: (BuildContext bc) => [
        favorites
                .where((element) =>
                    element.id.toString() == temp.id.toString())
                .isEmpty
            ? PopupMenuItem(
                onTap: () async {
                  favorites.add(temp);
                  await box.put("favorites", favorites);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(temp.title + " Added to Favorites"),
                    ),
                  );
                },
                child: Text("Add to favorite"),
              )
            : PopupMenuItem(
                onTap: () async {
                  favorites.removeWhere((element) =>
                      element.id.toString() == temp.id.toString());
                  await box.put("favorites", favorites);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(temp.title + " Removed from Favorites"),
                    ),
                  );
                },
                child: Text("Remove from favorite"),
              ),
        PopupMenuItem(
          child: Text("Add to playlist"),
          value: "1",
        ),
      ],
      onSelected: (value) async {
        if (value == "1") {
          showModalBottomSheet(
            context: context,
            builder: (context) => AddToPlaylist(song: temp),
          );
        }
      },
      icon: Icon(
        Icons.more_horiz,
        color: Colors.white,
      ),
    );
  }
}
