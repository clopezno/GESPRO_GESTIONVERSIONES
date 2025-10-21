import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/widgets/btn_follow_user.dart';

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

  Widget createTestWidget({required MapState initialState}) {
    when(() => mockMapBloc.state).thenReturn(initialState);

    return BlocProvider<MapBloc>.value(
      value: mockMapBloc,
      child: const MaterialApp(
        home: Scaffold(
          body: BtnFollowUser(),
        ),
      ),
    );
  }

  group('BtnFollowUser Tests', () {
    testWidgets('Muestra el botón de seguir al usuario', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(initialState: const MapState(isFollowingUser: false)));

      // Verifica que el botón de seguir al usuario es mostrado
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('Emite el evento OnStartFollowingUserEvent al presionar el botón',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(initialState: const MapState(isFollowingUser: false)));

      // Simula el tap en el botón
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Verifica que el evento OnStartFollowingUserEvent es emitido
      verify(() => mockMapBloc.add(const OnStartFollowingUserEvent())).called(1);
    });
  });
}
