import 'dart:async';

import 'package:shelf/shelf.dart';

Middleware proxy(TokenResolver resolver, {Authenticator authenticator}) =>
    (handler) {
      authenticator ??= (_) => null;
      return (request) async {
        final proxyToken = _extractToken(request);
        final user = await authenticator(proxyToken);
        final token = await resolver(user, request);
        return await handler(request.change(
            headers: {'Authorization': 'Bearer $token'},
            context: {'tesla_proxy.user': user}));
      };
    };

Middleware authBlocker() => (handler) => (request) async =>
    (request.method == 'POST' && request.url.path == 'oauth/token')
        ? Response.notFound('Authentication is not supported.')
        : handler(request);

class User {
  final String id;

  const User(this.id);
}

/// Returns an instance of [ProxyUser] by the incoming auth [token].
/// If no user found, returns null.
typedef FutureOr<User> Authenticator(String token);

/// Returns a real token for the given [user] and [request].
/// If the [user] is not allowed to perform the [request], returns null.
typedef FutureOr<String> TokenResolver(User user, Request request);

String _extractToken(Request r) {
  final auth = r.headers['Authorization'];
  if (auth == null) return null;
  final match = RegExp(r'^Bearer (.+)$').firstMatch(auth);
  if (match == null) return null;
  return match.group(1);
}
