import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:project_app/blocs/tour/tour_bloc.dart';
import 'package:project_app/blocs/map/map_bloc.dart';
import 'package:project_app/delegates/delegates.dart';

import 'package:project_app/services/places_service.dart';

class MockTourBloc extends Mock implements TourBloc {}
class MockMapBloc extends Mock implements MapBloc {}
class MockPlacesService extends Mock implements PlacesService {}

void main() {
  late MockTourBloc mockTourBloc;

  late SearchDestinationDelegate searchDelegate;

  setUpAll(() {
    dotenv.testLoad(mergeWith: {
      'GOOGLE_PLACES_API_KEY': 'mock-google-places-api-key',
      'FIREBASE_API_KEY': 'mock-firebase-api-key',
    });
  });

  setUp(() {
    mockTourBloc = MockTourBloc();

    searchDelegate = SearchDestinationDelegate();
  });

  group('SearchDestinationDelegate Tests', () {
    testWidgets('Limpia la búsqueda cuando se presiona el botón de limpiar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: mockTourBloc,
              child: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(context: context, delegate: searchDelegate);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Invoca el buscador
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      searchDelegate.query = 'some place';
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(searchDelegate.query, isEmpty);
    });

    testWidgets('Cierra el buscador cuando se presiona el botón de retroceso', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: mockTourBloc,
              child: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(context: context, delegate: searchDelegate);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Invoca el buscador
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Presiona el botón de retroceso
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(find.byType(SearchDestinationDelegate), findsNothing);
    });

 

    
  });
}