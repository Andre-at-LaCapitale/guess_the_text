import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guess_the_text/screens/game/game_bottom_widhet.dart';

import 'package:guess_the_text/screens/game/letters_widget.dart';
import 'package:guess_the_text/screens/game/work_session_conclusion_widget.dart';
import 'package:guess_the_text/screens/game/work_session_text_loading_widjet.dart';
import 'package:guess_the_text/screens/game/work_session_text_widget.dart';
import 'package:guess_the_text/model/word_to_guess.dart';
import 'package:guess_the_text/services/hangman_service.dart';

import 'app-menu/app_menu.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({Key? key}) : super(key: key);

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final HangmanService service = HangmanService();
  late TextToGuess textToGuess;
  Map data = {};
  bool isShuffling = false;

  @override
  void initState() {
    super.initState();

    String newText = service.shuffle().normalized;
    textToGuess = TextToGuess(characters: newText);
  }

  void reset() {
    setState(() {
      isShuffling = true;
    });

    const duration = Duration(milliseconds: 400);
    Timer(duration, () {
      var newText = service.shuffle().normalized;
      print('new text $newText');
      setState(() => ({textToGuess = TextToGuess(characters: newText), isShuffling = false}));
    });
  }

  void tryLetter(String c) {
    setState(() => textToGuess.tryChar(c: c));
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    String currentStateImg = "assets/images/${textToGuess.currentStateImage()}.png";

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        centerTitle: true,
        backgroundColor: Colors.orange[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isShuffling
                ? const WordSessionTextLoading()
                : WordSessionText(textToGuess: textToGuess, isHiddenMode: true),
            Expanded(child: Image.asset(currentStateImg)),
            GameBottomWidget(textToGuess: textToGuess, tryLetter: tryLetter),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: reset,
        child: const Icon(Icons.refresh),
      ),
      drawer: AppMenu(resetState: reset),
    );
  }
}
