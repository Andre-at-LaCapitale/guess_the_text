import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guess_the_text/services/hangman/model/api_category.dart';
import 'package:guess_the_text/services/hangman/texts.service.dart';
import 'package:guess_the_text/store/game/game.store.dart';
import 'package:guess_the_text/theme/app_bar/app_bar_title_widget.dart';
import 'package:guess_the_text/theme/theme_utils.dart';
import 'package:guess_the_text/utils/animations.dart';

import 'package:guess_the_text/utils/icon_utils.dart';
import 'package:lottie/lottie.dart';

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({Key? key}) : super(key: key);

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  final TextsService textsService = TextsService();
  final GameStore gameStore = GameStore();
  static const String backgroundImage = 'assets/images/backgrounds/background-pexels-pixabay-461940.jpg';

  bool isAppLoading = true;
  List<ApiCategory> categories = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    categories = await textsService.getCategories();
    setState(() {
      isAppLoading = false;
    });
  }

  void selectCategory(ApiCategory category, BuildContext context) async {
    await gameStore.selectCategory(category);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isAppLoading) {
      return Center(
        child: Lottie.asset(getAnimationPath()),
      );
    }

    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: localizations.categories),
      ),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(backgroundImage), fit: BoxFit.cover)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing(1)),
          child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(spacing(0.25)),
                  child: Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: ListTile(
                      onTap: () => selectCategory(categories[index], context),
                      leading: Icon(iconsMap[categories[index].name]), // add an iconName attribute to model
                      title: Text(
                        categories[index].name,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
