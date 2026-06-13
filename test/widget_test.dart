import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/dashboard_main_view.dart';
import 'package:smart_home/main.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  setUp(() {
    dotenv.loadFromString(envString: 'MQTT_BROKER_URL=broker.hivemq.com');
  });

  testWidgets('Smart Home Dashboard App smoke test', (WidgetTester tester) async {
    await HttpOverrides.runZoned(() async {
      // Set a tablet/desktop screen size (1440x900)
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      

      // Build our app and trigger a frame.
      await tester.pumpWidget(const SmartHomeApp());
      await tester.pumpAndSettle();

      // Verify that the main rooms from our mock data are present on screen.
      expect(find.text('Bedroom'), findsOneWidget);

      final roomsListView = find.descendant(
        of: find.byType(DashboardMainView),
        matching: find.byType(Scrollable),
      ).first;
      await tester.scrollUntilVisible(
        find.text('Living room'),
        50.0,
        scrollable: roomsListView,
      );
      await tester.pumpAndSettle();

      expect(find.text('Living room'), findsOneWidget);
    }, createHttpClient: (context) => MyHttpClient());
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MyHttpClient();
  }
}

class MyHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MyHttpClientRequest();
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MyHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return MyHttpClientResponse();
  }

  @override
  HttpHeaders get headers => MyHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MyHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MyHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// 1x1 transparent PNG image data
final List<int> _transparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];
