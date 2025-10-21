import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/gps_access_screen.dart';

// Mock del GpsBloc
class MockGpsBloc extends MockBloc<GpsEvent, GpsState> implements GpsBloc {}

void main() {
  late MockGpsBloc mockGpsBloc;

  setUp(() {
    mockGpsBloc = MockGpsBloc();
    registerFallbackValue(
      const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
    );
  });

  tearDown(() {
    mockGpsBloc.close();
  });

  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/gps-access',
      routes: [
        GoRoute(
          path: '/gps-access',
          builder: (context, state) => const GpsAccessScreen(),
        ),
        GoRoute(
          path: '/tour-selection',
          builder: (context, state) => const Scaffold(
            body: Text('Tour Selection Screen'),
          ),
        ),
      ],
    );
  }

  group('GpsAccessScreen Tests', () {
    testWidgets(
      'muestra el mensaje "Debe habilitar el GPS para continuar" cuando isGpsEnabled es false',
      (WidgetTester tester) async {
        when(() => mockGpsBloc.state).thenReturn(
          const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
        );

        await tester.pumpWidget(
          BlocProvider<GpsBloc>.value(
            value: mockGpsBloc,
            child: Builder(
              builder: (context) {
                final router = createTestRouter();
                return MaterialApp.router(
                  routerDelegate: router.routerDelegate,
                  routeInformationParser: router.routeInformationParser,
                  routeInformationProvider: router.routeInformationProvider,
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('enable_gps_message'.tr()),
          findsOneWidget,
        );
      },
    );

  });
}
