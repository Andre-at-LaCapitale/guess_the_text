import 'package:flutter/material.dart';
import 'package:guess_the_text/theme/theme.utils.dart';
import 'package:guess_the_text/theme/widgets/snackbar/snackbar.model.dart';

class SnackbarInfoWidget extends StatelessWidget {
  final String message;
  final SnackbarType type;

  const SnackbarInfoWidget({Key? key, required this.message, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(snackbarIcons[type], color: Colors.orange),
        Padding(
          padding: EdgeInsets.only(left: spacing(1)),
          child: Text(message),
        ),
      ],
    );
  }
}
