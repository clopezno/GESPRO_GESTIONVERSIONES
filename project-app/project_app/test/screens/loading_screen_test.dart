import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/loading_screen.dart';

// Mock del GpsBloc
class MockGpsBloc extends MockBloc<GpsEvent, GpsState> implements GpsBloc {}

void main() {
  late MockGpsBloc mockGpsBloc;

  setUp(() {
    mockGpsBloc = MockGpsBloc();
  });

  tearDown(() {
    mockGpsBloc.close();
  });

  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoadingScreen(),
        ),
        GoRoute(
          path: '/tour-selection',
          builder: (context, state) => const Scaffold(
            body: Text('Tour Selection Screen'),
          ),
        ),
        GoRoute(
          path: '/gps-access',
          builder: (context, state) => const Scaffold(
            body: Text('GPS Access Screen'),
          ),
        ),
      ],
    );
  }

  group('LoadingScreen', () {
    testWidgets(
      'navega a /tour-selection cuando isAllReady es true',
      (WidgetTester tester) async {
        // Configurar el estado inicial del Bloc
        when(() => mockGpsBloc.state).thenReturn(
          const GpsState(isGpsEnabled: true, isGpsPermissionGranted: true),
        );

        // Simular la emisión de estados por el Bloc
        whenListen(
          mockGpsBloc,
          Stream.fromIterable([
            const GpsState(isGpsEnabled: true, isGpsPermissionGranted: true),
          ]),
        );

        // Construir el widget
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

        // Esperar la transición de estado
        await tester.pumpAndSettle();

        // Verificar que la navegación ocurrió correctamente
        expect(find.text('Tour Selection Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'navega a /gps-access cuando isAllReady es false',
      (WidgetTester tester) async {
        // Configurar el estado inicial del Bloc
        when(() => mockGpsBloc.state).thenReturn(
          const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
        );

        // Simular la emisión de estados por el Bloc
        whenListen(
          mockGpsBloc,
          Stream.fromIterable([
            const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
          ]),
        );

        // Construir el widget
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

        // Esperar la transición de estado
        await tester.pumpAndSettle();

        // Verificar que la navegación ocurrió correctamente
        expect(find.text('GPS Access Screen'), findsOneWidget);
      },
    );
  });
}
