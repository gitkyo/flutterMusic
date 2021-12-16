import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_player/musique.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() {
  runApp(MyApp());
}

// epi 8 lecteur de musik
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Music player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Music player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> maListeDeMusique = [
    new Musique('titre 1 ', 'artiste 1 ', 'assets/cantine.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Musique('titre 2 ', 'artiste 2 ', 'assets/feux_resultat.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Musique maMusiqueActuel;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    maMusiqueActuel = maListeDeMusique[index];
    configurationAudioplayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
                elevation: 9.0,
                child: new Container(
                  width: MediaQuery.of(context).size.height / 2.5,
                  child: new Image.asset(maMusiqueActuel.imagePath),
                )),
            texteAvecStyle(maMusiqueActuel.titre, 1.5),
            texteAvecStyle(maMusiqueActuel.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton(
                    (statut == PlayerState.playing)
                        ? Icons.pause
                        : Icons.play_arrow,
                    45.0,
                    (statut == PlayerState.playing)
                        ? ActionMusic.pause
                        : ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle(fromDuration(position), 0.8),
                texteAvecStyle(fromDuration(duree), 0.8),
              ],
            ),
            new Slider(
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: 30.0,
              inactiveColor: Colors.white,
              activeColor: Colors.red,
              onChanged: (double d) {
                setState(() {
                  Duration nouvelleDuration = new Duration(seconds: d.toInt());
                  position = nouvelleDuration;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action) {
    return new IconButton(
      icon: new Icon(icone),
      color: Colors.white,
      onPressed: () {
        switch (action) {
          case ActionMusic.play:
            play();
            break;
          case ActionMusic.pause:
            pause();
            break;
          case ActionMusic.forward:
            forward();
            break;
          case ActionMusic.rewind:
            rewind();
            break;
        }
      },
    );
  }

  Text texteAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
          color: Colors.white, fontSize: 20.0, fontStyle: FontStyle.italic),
    );
  }

  void configurationAudioplayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print('erreur : $message');
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(maMusiqueActuel.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.pause;
    });
  }

  void forward() {
    if (index == maListeDeMusique.length - 1)
      index = 0;
    else
      index++;
    maMusiqueActuel = maListeDeMusique[index];
    audioPlayer.stop();
    configurationAudioplayer();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 2)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = maListeDeMusique.length - 1;
      } else {
        index--;
      }
      maMusiqueActuel = maListeDeMusique[index];
      audioPlayer.stop();
      configurationAudioplayer();
      play();
    }
  }

  String fromDuration(Duration duree) {
    print(duree);
    return duree.toString().split('.').first;
  }
}

enum ActionMusic { play, pause, rewind, forward }
enum PlayerState { playing, stopped, pause }
