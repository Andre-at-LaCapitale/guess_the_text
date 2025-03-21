import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guess_the_text/services/text.service/api.about.model.dart';
import 'package:guess_the_text/services/text.service/api.texts.service.dart';
import 'package:guess_the_text/theme/widgets/compact.datatable.widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/service.locator.dart';
import '/theme/widgets/text.link.widget.dart';
import 'card.app.connectivity.status.dart';

class AppVersionTable extends StatefulWidget {
  const AppVersionTable({Key? key}) : super(key: key);

  @override
  State<AppVersionTable> createState() => _AppVersionTableState();
}

class _AppVersionTableState extends State<AppVersionTable> {
  final TextsService _textsService = serviceLocator.get();

  String _appVersion = '';
  String _appBuildNumber = '';
  ApiAbout _apiAbout = const ApiAbout();

  @override
  void initState() {
    super.initState();

    _textsService.getAboutInfo().then((value) => {
          if (mounted)
            setState(() {
              _apiAbout = value;
            })
        });

    PackageInfo.fromPlatform().then((packageInfo) {
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _appBuildNumber = packageInfo.buildNumber;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        CompactDatatableWidget(
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text(localizations.appVersion)),
                DataCell(Text(_appVersion)),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text(localizations.appBuildNumber)),
                DataCell(Text(_appBuildNumber)),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text(localizations.appBackendName)),
                DataCell(Text(_apiAbout.name)),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text(localizations.appBackendVersion)),
                DataCell(Text(_apiAbout.version)),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text(localizations.connectivityStatus)),
                const DataCell(ConnectivityStatusWidget()),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text(localizations.githubProject)),
                const DataCell(
                  ThemedTextLink(
                      displayText: 'Open Source project', hyperlink: 'https://github.com/amwebexpert/guess_the_text'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
