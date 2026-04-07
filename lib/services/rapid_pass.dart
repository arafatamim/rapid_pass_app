import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rapid_pass_info/helpers/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:http/io_client.dart';
import 'package:rapid_pass_info/models/transit_card.dart';

http.Client makeClient() {
  var ioClient = HttpClient();
  ioClient.connectionTimeout = const Duration(seconds: 20);
  return IOClient(ioClient);
}

class AuthenticatedSession {
  final String username;
  final List<Cookie> cookies;
  final Uri redirectUri;

  AuthenticatedSession({
    required this.username,
    required this.cookies,
    required this.redirectUri,
  });

  Cookie? getCookie(String name) {
    return cookies.firstWhereOrNull((cookie) => cookie.name == name);
  }

  String get cookieString =>
      cookies.map((cookie) => "${cookie.name}=${cookie.value}").join("; ");

  String toJson() {
    return jsonEncode({
      'cookies': cookies
          .map((cookie) => {
                'name': cookie.name,
                'value': cookie.value,
                'domain': cookie.domain,
                'path': cookie.path,
                'expires': cookie.expires?.toIso8601String(),
                'maxAge': cookie.maxAge,
                'secure': cookie.secure,
                'httpOnly': cookie.httpOnly,
                'sameSite': cookie.sameSite?.name,
              })
          .toList(),
      'redirectUri': redirectUri.toString(),
    });
  }

  @override
  String toString() {
    return 'AuthenticatedSession(cookies: $cookies, redirectUri: $redirectUri, username: $username)';
  }
}

class RapidPassService {
  final http.Client client;

  RapidPassService._() : client = makeClient();

  static final instance = RapidPassService._();

  static const String _baseUrl = "https://rapidpass.com.bd";

  /// Returns a cookie that can be used to authenticate with the RapidPass API.
  Future<AuthenticatedSession> login({
    required String username,
    required String password,
  }) async {
    try {
      final loginUri = Uri.parse("$_baseUrl/login");

      final loginPageRes = await client.get(loginUri);

      final cookies = [
        for (final cookie
            in loginPageRes.headersSplitValues["set-cookie"] ?? [])
          Cookie.fromSetCookieValue(cookie)
      ];

      final xsrfToken = cookies.firstWhere((c) => c.name == "XSRF-TOKEN");
      final sessionToken =
          cookies.firstWhere((c) => c.name == "rapidpass_session");
      final locale = cookies.firstWhere((c) => c.name == "locale");

      final document = dom.Document.html(loginPageRes.body);
      final csrfToken = document
          .querySelector("meta[name='csrf-token']")
          ?.attributes['content'];

      if (csrfToken == null) {
        throw AppException(AppExceptionType.auth);
      }

      final loginRes = await client.post(
        loginUri,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Cookie":
              "rapidpass_session=${sessionToken.value}; locale=${locale.value}; XSRF-TOKEN=${xsrfToken.value}"
        },
        body: {
          "_token": csrfToken,
          "email_or_mobile": username,
          "password": password,
          "submit": ""
        },
      );
      final redirectUri = loginRes.headers['location'];
      if (redirectUri == null || !redirectUri.contains("home")) {
        throw AppException(AppExceptionType.auth);
      }

      final newCookies = [
        for (final cookie in loginRes.headersSplitValues["set-cookie"] ?? [])
          Cookie.fromSetCookieValue(cookie)
      ];

      return AuthenticatedSession(
        redirectUri: Uri.parse(redirectUri),
        cookies: newCookies,
        username: username,
      );
    } on SocketException {
      throw AppException(AppExceptionType.network);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  Future<List<TransitCard>> getCards(AuthenticatedSession session) async {
    final dashboardUri = session.redirectUri;
    final res = await client.get(dashboardUri, headers: {
      "Cookie": session.cookieString,
    });

    final doc = dom.Document.html(res.body);

    final cardsHtml = doc.querySelectorAll("._rp_card > .info > a");

    final cards = <TransitCard>[];
    for (final card in cardsHtml) {
      final clickEvent = card.attributes["@click"];

      // Extract JSON from inside function call
      final regex = RegExp(r'\w+\((.*)\)');
      final match = regex.firstMatch(clickEvent ?? '');

      if (match != null && match.groupCount > 0) {
        final matchedString = match.group(1);
        if (matchedString != null) {
          try {
            final cardJson = jsonDecode(matchedString);
            cards.add(TransitCard.fromJson(cardJson, session.username));
          } catch (e) {
            debugPrint('Error parsing JSON: $e');
            continue;
          }
        }
      }
    }

    return cards;
  }
}
