import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:guess_the_text/features/game/text.to.guess.shuffling.widget.dart';
import 'package:guess_the_text/theme/app.theme.dart';

class TextToGuessTemplate extends StatelessWidget {
  const TextToGuessTemplate({
    Key? key,
    required this.text,
    required this.isAnimated,
    required this.isLoading,
  }) : super(key: key);

  final String text;
  final bool isAnimated;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TextToGuessShuffling();
    }

    final textStyle = TextStyle(
      fontSize: 36,
      fontFamily: appFontFamily,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
      color: Theme.of(context).colorScheme.primary,
    );

    return isAnimated
        ? DefaultTextStyle(
            style: textStyle,
            child: AnimatedTextKit(
              animatedTexts: [WavyAnimatedText(text)],
              isRepeatingAnimation: true,
            ),
          )
        : Text(text, style: textStyle);
  }
}
