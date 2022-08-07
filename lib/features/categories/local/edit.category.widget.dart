import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guess_the_text/features/categories/category.icons.map.dart';
import 'package:guess_the_text/features/settings/settings.store.dart';
import 'package:guess_the_text/service.locator.dart';
import 'package:guess_the_text/services/logger/logger.service.dart';
import 'package:guess_the_text/services/text.service/api.category.model.dart';
import 'package:guess_the_text/services/text.service/sql.db.service.dart';
import 'package:guess_the_text/theme/theme.utils.dart';
import 'package:guess_the_text/utils/extensions/string.extensions.dart';
import 'package:guess_the_text/utils/language.utils.dart';
import 'package:uuid/uuid.dart';

class EditCategory extends StatefulWidget {
  final ApiCategory category;
  final bool isNew;

  const EditCategory({Key? key, required this.category, required this.isNew}) : super(key: key);

  @override
  EditCategoryState createState() => EditCategoryState();
}

class EditCategoryState extends State<EditCategory> {
  final LoggerService loggerService = serviceLocator.get();
  final SqlDbService sqlDbService = serviceLocator.get();
  final SettingsStore settings = serviceLocator.get();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtCategoryController = TextEditingController();
  late String _langCode;
  late String _iconName;

  @override
  void initState() {
    if (widget.isNew) {
      _langCode = settings.locale.languageCode;
      _iconName = defaultCategoryIcon;
    } else {
      _txtCategoryController.text = widget.category.name;
      _langCode = widget.category.langCode;
      _iconName = widget.category.iconName;
    }

    super.initState();
  }

  @override
  void dispose() {
    _txtCategoryController.dispose();
    super.dispose();
  }

  Future<ApiCategory?> _saveCategory(BuildContext context) async {
    final name = _txtCategoryController.text;

    if (widget.isNew) {
      final category = ApiCategory(uuid: const Uuid().v4(), name: name, langCode: _langCode, iconName: _iconName);
      return sqlDbService.createCategory(category);
    } else {
      final category = widget.category.copyWith(name: name, langCode: _langCode, iconName: _iconName);
      return sqlDbService.updateCategory(category);
    }
  }

  void _onLanguageChange(String? value) {
    setState(() => _langCode = value ?? settings.locale.languageCode);
  }

  void _onCategoryIconChange(String? value) {
    setState(() => _iconName = value ?? defaultCategoryIcon);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final title = widget.isNew ? Text(localizations.categoryNew) : Text(localizations.categoryEdit);

    return AlertDialog(
      title: title,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormFieldCategoryName(controller: _txtCategoryController),
              Row(
                children: [
                  Expanded(child: DropDownButtonFieldLanguage(value: _langCode, onChanged: _onLanguageChange)),
                  SizedBox(width: spacing(2)),
                  SizedBox(
                    width: 50,
                    child: DropDownButtonFieldIcon(value: _iconName, onChanged: _onCategoryIconChange),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localizations.actionCancel)),
        ElevatedButton(
          child: Text(localizations.actionOK),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _saveCategory(context).then((value) => Navigator.pop(context, value));
            }
          },
        ),
      ],
    );
  }
}

class DropDownButtonFieldIcon extends StatelessWidget {
  const DropDownButtonFieldIcon({Key? key, required this.value, required this.onChanged}) : super(key: key);

  final String value;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      items: categoryIcons.entries.map((e) => DropdownMenuItem(value: e.key, child: Icon(e.value))).toList(),
      hint: Text(localizations.categoryIcon),
      isExpanded: true,
      isDense: true,
      value: value,
      onChanged: onChanged,
    );
  }
}

class DropDownButtonFieldLanguage extends StatelessWidget {
  const DropDownButtonFieldLanguage({Key? key, required this.value, required this.onChanged}) : super(key: key);

  final String value;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      items: [
        DropdownMenuItem(
          value: AppLanguage.en.name,
          child: Text(localizations.prefLangEn, style: Theme.of(context).textTheme.bodyText1),
        ),
        DropdownMenuItem(
          value: AppLanguage.fr.name,
          child: Text(localizations.prefLangFr, style: Theme.of(context).textTheme.bodyText1),
        ),
      ],
      hint: Text(localizations.language),
      value: value,
      onChanged: onChanged,
    );
  }
}

class TextFormFieldCategoryName extends StatelessWidget {
  final TextEditingController controller;

  const TextFormFieldCategoryName({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return TextFormField(
      autofocus: controller.text.isBlank,
      enableSuggestions: false,
      autocorrect: false,
      controller: controller,
      validator: (value) => value.isBlank ? localizations.fieldValidationMandatory : null,
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(hintText: localizations.category),
    );
  }
}
