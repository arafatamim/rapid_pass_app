import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/state/state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPassPage extends StatefulWidget {
  const AddPassPage({super.key});

  @override
  State<AddPassPage> createState() => _AddPassPageState();
}

class _AddPassPageState extends State<AddPassPage> {
  int? cardNumber;
  String? name;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addRapidPass),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 14,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.cardNumberHint,
                  prefixText: "RP",
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      value.length != 14) {
                    return AppLocalizations.of(context)!.cardNumberValidator;
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    cardNumber = int.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.cardNameHint,
                ),
                maxLength: 15,
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
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  _formKey.currentState!.save();
                  if (cardNumber == null || name == null) {
                    return;
                  }
                  context.read<AppState>().addPass(name!, cardNumber!);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(AppLocalizations.of(context)!.addRapidPass),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
