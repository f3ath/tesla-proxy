import 'package:shelf/shelf.dart';
import 'package:tesla_proxy/tesla_proxy.dart' as tesla;
import 'package:test/test.dart';

void main() {
  group('Proxy', () {
    test('substitutes token', () async {
      final Handler handler = (Request r) {
        expect(r.headers['Authorization'], 'Bearer real_token');
        return Response.ok('Yo');
      };

      final tesla.TokenResolver resolver = (user, request) => 'real_token';

      final req = Request('GET', Uri.parse('http://my-proxy/get_stuff'),
          headers: {'Authorization': 'Bearer proxy_user_token'});
      final response = await tesla.proxy(
        resolver,
        authenticator: (_) => tesla.User('default'),
      )(handler)(req);
      expect(await response.readAsString(), 'Yo');
    });
  });

  group('Auth blocker', () {
    test('responds 404 to POST /oauth/token', () async {
      final Handler handler = (Request r) {
        return Response.ok('Yo');
      };

      final req = Request('POST', Uri.parse('http://my-proxy/oauth/token'));
      final response = await tesla.authBlocker()(handler)(req);
      expect(await response.readAsString(), 'Authentication is not supported.');
      expect(response.statusCode, 404);
    });
  });
}
