import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ps_deals/main.dart';
import 'package:ps_deals/widgets/game_card.dart';

/// Minimal in-memory HTTP client so widget tests can load the cover images
/// without any real network access. Every GET returns a 1x1 transparent PNG;
/// all other members are no-ops / safe defaults.
class _FakeHttpClient implements HttpClient {
  // A 1x1 transparent PNG.
  static final Uint8List _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
  );

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeRequest(_FakeResponse(_png));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRequest implements HttpClientRequest {
  _FakeRequest(this._response);
  final HttpClientResponse _response;

  @override
  Future<HttpClientResponse> close() async => _response;

  // HttpClientRequest extends IOSink, which declares many members the image
  // loader never touches. Forward them all to noSuchMethod.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeResponse extends Stream<List<int>> implements HttpClientResponse {
  _FakeResponse(this._bytes);
  final Uint8List _bytes;

  @override
  int statusCode = 200;

  @override
  String reasonPhrase = 'OK';

  @override
  HttpHeaders headers = _FakeHeaders();

  @override
  List<Cookie> cookies = const [];

  @override
  int contentLength = 1;

  @override
  X509Certificate? certificate;

  @override
  HttpClientResponseCompressionState compressionState =
      HttpClientResponseCompressionState.notCompressed;

  @override
  bool isRedirect = false;

  @override
  List<RedirectInfo> redirects = const [];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      Stream<List<int>>.fromIterable([_bytes]).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  // The remaining HttpClientResponse members (connectionInfo, redirect,
  // detachSocket) are never used by the image loader, so we forward them to
  // noSuchMethod rather than declaring them with internal-only types.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  testWidgets('App boots and renders deal cards', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PlayStationDealsApp()));
    await tester.pumpAndSettle();

    expect(find.text('PlayStation Deals'), findsOneWidget);
    expect(find.text('Toon deals met 50%+ korting'), findsOneWidget);
    // At least one game card is rendered from the mock dataset.
    expect(find.byType(GameCard), findsWidgets);
  });

  testWidgets('Default threshold shows multiple deals',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PlayStationDealsApp()));
    await tester.pumpAndSettle();

    // At the default 50% filter there are many deals in the grid.
    expect(find.byType(GameCard), findsWidgets);
    // The empty-state reset button must NOT be present by default.
    expect(find.text('Reset to 50%'), findsNothing);
  });
}
