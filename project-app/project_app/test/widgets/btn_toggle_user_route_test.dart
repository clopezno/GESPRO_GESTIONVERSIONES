import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/widgets/btn_toggle_user_route.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

class FakeMapEvent extends Fake implements MapEvent {}

void main() {
  late MockMapBloc mockMapBloc;

  setUpAll(() {
    registerFallbackValue(FakeMapEvent());
  });

  setUp(() {
    mockMapBloc = MockMapBloc();
  });

  Widget createTestWidget(MapState initialState) {
    when(() => mockMapBloc.state).thenReturn(initialState);

    return MaterialApp(
      home: BlocProvider<MapBloc>.value(
        value: mockMapBloc,
        child: const Scaffold(
          body: BtnToggleUserRoute(),
        ),
      ),
    );
  }

  group('BtnToggleUserRoute Tests', () {
    testWidgets('Renderiza correctamente el ícono inicial', (tester) async {
      const initialState = MapState(showUserRoute: false);
      await tester.pumpWidget(createTestWidget(initialState));

      // Verificar que el ícono inicial es el esperado
      expect(find.byIcon(Icons.draw_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mode_rounded), findsNothing);
    });

    testWidgets('Cambia el ícono cuando cambia el estado', (tester) async {
  const initialState = MapState(showUserRoute: false);

  // Configura el mock para devolver un flujo de estados
  when(() => mockMapBloc.state).thenReturn(initialState);
  whenListen(
    mockMapBloc,
    Stream.fromIterable([
      initialState,
      const MapState(showUserRoute: true), // Estado actualizado
    ]),
  );

  await tester.pumpWidget(createTestWidget(initialState));

  // Verifica el estado inicial
  expect(find.byIcon(Icons.draw_rounded), findsOneWidget);
  expect(find.byIcon(Icons.mode_rounded), findsNothing);

  // Espera a que el estado cambie
  await tester.pumpAndSettle();

  // Verifica el estado actualizado
  expect(find.byIcon(Icons.mode_rounded), findsOneWidget);
  expect(find.byIcon(Icons.draw_rounded), findsNothing);
});


    testWidgets('Dispara OnToggleShowUserRouteEvent al hacer clic',
        (tester) async {
      const initialState = MapState(showUserRoute: false);
      await tester.pumpWidget(createTestWidget(initialState));

      // Simula el clic en el botón
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Verificar que se envió el evento al bloc
      verify(() => mockMapBloc.add(const OnToggleShowUserRouteEvent())).called(1);
    });
  });
}
