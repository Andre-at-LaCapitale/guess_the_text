import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guess_the_text/features/game/game.layout.landscape.widget.dart';
import 'package:guess_the_text/features/game/game.layout.portrait.widget.dart';
import 'package:guess_the_text/features/game/challenge/on.the.fly.challenge.model.dart';
import 'package:guess_the_text/features/game/challenge/edit.text.to.guess.widget.dart';
import 'package:guess_the_text/service.locator.dart';
import 'package:guess_the_text/services/logger/logger.service.dart';
import 'package:guess_the_text/features/game/game.store.dart';
import 'package:guess_the_text/services/qr/qr.code.service.dart';
import 'package:guess_the_text/store/fixed.delay.spinner.store.dart';
import 'package:guess_the_text/store/store.state.enum.dart';
import 'package:guess_the_text/theme/widgets/app.bar.title.widget.dart';
import 'package:guess_the_text/theme/widgets/app.menu.widget.dart';
import 'package:guess_the_text/theme/widgets/snackbar/snackbar.info.widget.dart';
import 'package:guess_the_text/utils/extensions/string.extensions.dart';
import 'package:mobx/mobx.dart';

import 'game.layout.landscape.widget.dart';
import 'game.layout.portrait.widget.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({Key? key}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final GameStore gameStore = serviceLocator.get();
  final QrCodeService qrCodeService = serviceLocator.get();
  final FixedDelaySpinnerStore spinnerStore = serviceLocator.get();
  final LoggerService logger = serviceLocator.get();

  List<ReactionDisposer> disposers = [];

  @override
  void initState() {
    super.initState();

    final ReactionDisposer disposer = reaction((_) => spinnerStore.state, (StoreState storeState) {
      logger.info('Example of a reaction on spinnerStore.state change $storeState');
    });
    disposers.add(disposer);
  }

  @override
  void dispose() {
    for (var disposer in disposers) {
      disposer();
    }

    super.dispose();
  }

  void shuffle(BuildContext context) {
    if (gameStore.currentCategory.isCustom) {
      onCreateChallengePress(context);
    } else {
      spinnerStore.spin(milliseconds: 400);
      gameStore.shuffle();
    }
  }

  void onCreateChallengePress(BuildContext context) {
    showDialog(context: context, builder: (context) => const EditTextToGuessDialog());
  }

  void onAcceptChallengePress(BuildContext context) async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String jsonChallenge = await qrCodeService.scan(cancelLabel: localizations.actionCancel);

    if (jsonChallenge.isBlank) {
      ScaffoldMessenger.of(super.context).showSnackBar(SnackBar(
        content: SnackbarInfoWidget(message: localizations.acceptChallengeCancelled),
        duration: const Duration(seconds: 2),
      ));

      return;
    }

    spinnerStore.spin(milliseconds: 400);
    final OnTheFlyChallenge onTheFlyChallenge = OnTheFlyChallenge.fromJson(jsonChallenge);
    gameStore.adhocText(onTheFlyChallenge.text, localizations.adhocTextHint);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: localizations.appTitle),
      ),
      drawer: AppMenu(onCreateChallengePress: onCreateChallengePress, onAcceptChallengePress: onAcceptChallengePress),
      body: OrientationBuilder(builder: (context, orientation) {
        return orientation == Orientation.portrait ? GameLayoutPortraitWidget() : GameLayoutLandscapeWidget();
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () => shuffle(context),
        tooltip: 'Shuffle',
        child: const Icon(Icons.refresh), // TODO translate me i18n
      ),
    );
  }
}
