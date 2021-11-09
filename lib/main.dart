import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/pages/bottom_play.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:google_fonts/google_fonts.dart';
import './pages/home_page.dart';
import './pages/library_page.dart';
import './pages/search_page.dart';
import 'databases/songs_adapter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SongsAdapter());
  await Hive.openBox('songs');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  void initState() {
    requesrpermisson();
    super.initState();
  }

  List<Songs> audio = [];
  List<SongModel> tracks = [];
  var musics;
  requesrpermisson() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }
    tracks = await _audioQuery.querySongs();
    audio = tracks
        .map(
          (e) => Songs(
            title: e.title,
            artist: e.artist,
            uri: e.uri,
            duration: e.duration,
            id: e.id,
          ),
        )
        .toList();
    musics = Hive.box('songs');
    musics.put("tracks", audio);
    setState(() {});
  }

  int currentIndex = 0;

  final screens = [
    Homepage(),
    SearchPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            children: screens,
            index: currentIndex,
          ),
          bottomPlating(audio: audio),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 25,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
        backgroundColor: Colors.black,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: (index) => setState(
          () {
            // var music = Hive.box("songs");
            // List<Songs> a = music.get("tracks");
            // print(a[0].title);
            currentIndex = index;
          },
        ),
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/home.png"),
              size: 25,
            ),
            label: 'Home',
            // backgroundColor: Color(_black),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/search.png"),
              size: 25,
            ),
            label: 'Search',
            // backgroundColor: Color(_black),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/library.png"),
              size: 25,
            ),
            label: 'Library',
            // backgroundColor: Color(_black),
          ),
        ],
      ),
    );
  }
}
