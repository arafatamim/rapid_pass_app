import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid_pass_info/l10n/app_localizations.dart';
import 'package:rapid_pass_info/pages/home_page.dart';
import 'package:rapid_pass_info/services/auth_service.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';
import 'package:rapid_pass_info/store/state.dart';
import 'package:rapid_pass_info/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  final String? initialMessage;

  const LoginPage({super.key, this.initialMessage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final bool _rememberMe = true;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.login,
          style: textTheme.titleLarge,
        ),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or app name
                    Text(
                      AppLocalizations.of(context)!.title,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.emailOrPhone,
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.emailValidation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .passwordValidation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: _launchForgotPasswordURL,
                          child: Text(
                            AppLocalizations.of(context)!.forgotPassword,
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    _isSubmitting
                        ? const SizedBox(
                            height: 64,
                            width: 64,
                            child: LoadingIndicator(),
                          )
                        : FilledButton(
                            onPressed: _submitForm,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.login,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                    const SizedBox(height: 24),

                    // Register link
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: AppLocalizations.of(context)!.createAnAccount,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.fontFamily,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _launchRegistrationURL,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.initialMessage!)),
      );
    }
    _loadSavedCredentials();
  }

  Future<void> _launchForgotPasswordURL() async {
    final Uri url = Uri.parse('https://rapidpass.com.bd/password/reset');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open password reset page')),
        );
      }
    }
  }

  Future<void> _launchRegistrationURL() async {
    final Uri url = Uri.parse('https://rapidpass.com.bd/register');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open registration page')),
        );
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    final rememberMe = await AuthService.instance.getRememberMe();
    if (rememberMe) {
      debugPrint('Loading saved credentials...');
      final credentials = await AuthService.instance.getSavedCredentials();
      if (credentials['username'] != null) {
        _usernameController.text = credentials['username']!;
      }
      if (credentials['password'] != null) {
        _passwordController.text = credentials['password']!;
      }
    }
    setState(() {
      // _rememberMe = rememberMe;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final session = await RapidPassService.instance.login(
          username: _usernameController.text,
          password: _passwordController.text,
        );

        if (_rememberMe) {
          debugPrint('Saving credentials...');
          await AuthService.instance.saveCredentials(
            _usernameController.text,
            _passwordController.text,
          );
          await AuthService.instance.setRememberMe(true);
        } else {
          debugPrint('Not saving credentials...');
          await AuthService.instance.clearCredentials();
        }

        final cards = await RapidPassService.instance.getCards(session);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => CardsModel(
                  session: session,
                  cards: cards,
                ),
                builder: (context, child) => const HomePage(),
              ),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.loginFailed),
            ),
          );
        }
      }
    }
  }
}
