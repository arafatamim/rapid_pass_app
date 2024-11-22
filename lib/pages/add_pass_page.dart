import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPassPage extends StatefulWidget {
  const AddPassPage({super.key});

  @override
  State<AddPassPage> createState() => _AddPassPageState();
}

class _AddPassPageState extends State<AddPassPage> {
  String? id;
  String? name;
  String _prefix = "RP";

  final _formKey = GlobalKey<FormState>();

  void switchPrefix() {
    setState(() {
      _prefix = switch (_prefix) {
        "RP" => "DC",
        "DC" => "MP",
        "MP" => "RP",
        _ => "RP",
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        AppBar(
          automaticallyImplyLeading: false,
          title: Text(AppLocalizations.of(context)!.addRapidPass),
          backgroundColor: Colors.transparent,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  maxLength: 14,
                  maxLengthEnforcement:
                      MaxLengthEnforcement.truncateAfterCompositionEnds,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.cardNumberHint,
                    prefix: InkWell(
                      onTap: () => switchPrefix(),
                      child: Text(_prefix),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 14) {
                      return AppLocalizations.of(context)!.cardNumberValidator;
                    }
                    final idWithPrefix = "$_prefix$value";
                    final passExists = Hive.box<RapidPass>(RapidPass.boxName)
                        .values
                        .any((element) => element.id == idWithPrefix);
                    if (passExists) {
                      return AppLocalizations.of(context)!.cardNumberExists;
                    }

                    return null;
                  },
                  onSaved: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      id = value;
                    });
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.cardNameHint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.cardNameValidator;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    _formKey.currentState!.save();
                    if (id == null || name == null) {
                      return;
                    }

                    final pass = RapidPass("$_prefix${id!}", name!);

                    Hive.box<RapidPass>(RapidPass.boxName).add(pass);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AppLocalizations.of(context)!.addRapidPass),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
