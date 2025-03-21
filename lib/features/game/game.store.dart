import 'dart:math';

import 'package:guess_the_text/services/storage/shared.preferences.enum.dart';
import 'package:guess_the_text/services/storage/shared.preferences.services.dart';
import 'package:guess_the_text/services/text.service/api.category.model.dart';
import 'package:guess_the_text/services/text.service/api.text.model.dart';
import 'package:guess_the_text/services/text.service/api.texts.service.dart';
import 'package:mobx/mobx.dart';

import '/features/game/game.played.items.storage.service.dart';
import '/features/game/text_to_guess/text.to.guess.model.dart';
import '/service.locator.dart';
import '/services/logger/logger.service.dart';
import '/utils/extensions/string.extensions.dart';

// Include generated file
part 'game.store.g.dart';

// This is the class used by rest of the codebase
class GameStore extends _GameStoreBase with _$GameStore {}

// The store-class
abstract class _GameStoreBase with Store {
  final LoggerService logger = serviceLocator.get();
  final SharedPreferencesService sp = serviceLocator.get();
  final TextsService textsService = serviceLocator.get();
  final GamePlayedItemsStorageService gamePlayedItemsStorageService = serviceLocator.get();

  @observable
  ApiCategory currentCategory = const ApiCategory();

  @observable
  TextToGuess textToGuess = TextToGuess();

  @observable
  List<String> currentCategoryPlayedItems = [];

  _GameStoreBase() {
    _initialize();
  }

  Future<void> _initialize() async {
    List<ApiCategory> categories = await textsService.getCategories();

    String lastSelectedCategoryUuid =
        sp.getString(SharedPreferenceKey.lastSelectedCategory.name, defaultValue: categories.first.uuid);
    ApiCategory initialCategory = categories.where((element) => element.uuid == lastSelectedCategoryUuid).first;

    await selectCategory(initialCategory);
  }

  @action
  Future<void> selectCategory(ApiCategory selected) async {
    if (currentCategory.uuid == selected.uuid) {
      return;
    }

    sp.setString(SharedPreferenceKey.lastSelectedCategory.name, selected.uuid).onError((e, stackTrace) {
      logger.error("Can't write preference ${SharedPreferenceKey.lastSelectedCategory}", e, stackTrace: stackTrace);
      return false;
    });

    currentCategory = selected;
    currentCategoryPlayedItems = await gamePlayedItemsStorageService.getPlayedItems(currentCategory.uuid);
    await shuffle();
  }

  @action
  Future<void> shuffle() async {
    List<ApiText> texts = await _loadUnguessedTexts();

    int i = Random(DateTime.now().millisecondsSinceEpoch).nextInt(texts.length);
    ApiText apiText = texts.elementAt(i);
    textToGuess = TextToGuess(characters: apiText.normalized, original: apiText.original);
    logger.info('shuffled text: ${textToGuess.characters}');
  }

  Future<List<ApiText>> _loadUnguessedTexts() async {
    List<ApiText> apiTexts = await textsService.getTexts(currentCategory.uuid);

    // protection against all texts being played
    if (currentCategoryPlayedItems.length == apiTexts.length) {
      logger.info('all texts have been played for category "${currentCategory.name}". Resetting memoized items.');
      await gamePlayedItemsStorageService.clearCategoryPlayedItems(currentCategory.uuid);
      currentCategoryPlayedItems = [];
    }

    // get only the texts that have not been played yet
    apiTexts = apiTexts.where((apiText) => !currentCategoryPlayedItems.contains(apiText.original)).toList();

    logger
      ..info('--> ${currentCategoryPlayedItems.length} elements played: [${currentCategoryPlayedItems.join(', ')}]')
      ..info('--> ${apiTexts.length} texts remaining');
    return apiTexts;
  }

  @action
  Future<void> tryLetter(String c) async {
    textToGuess = textToGuess.tryChar(c: c);

    if (textToGuess.isGameOver()) {
      currentCategoryPlayedItems =
          await gamePlayedItemsStorageService.addPlayedItem(currentCategory.uuid, textToGuess.original);
    }
  }

  @action
  void adhocText(String newText, String categoryName) {
    currentCategory = ApiCategory(uuid: 'adhoc', name: categoryName, isCustom: true);
    final normalized = newText.removeDiacritics()!.toUpperCase();
    textToGuess = TextToGuess(characters: normalized, original: newText);
    logger.info('ADHOC text: ${textToGuess.characters}');
  }

  @computed
  String get currentStateImg => 'assets/images/${textToGuess.currentStateName()}.svg';

  @computed
  String get gameOverImage => 'assets/images/${textToGuess.gameOverConclusionName()}.svg';
}
