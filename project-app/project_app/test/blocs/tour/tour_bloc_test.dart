import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:mockito/mockito.dart';
import 'package:project_app/blocs/blocs.dart';

import 'package:project_app/persistence_bd/repositories/repositories.dart';
import 'package:project_app/services/services.dart';

class MockOptimizationService extends Mock implements OptimizationService {}

class MockEcoCityTourRepository extends Mock implements EcoCityTourRepository {}

class MockMapBloc extends Mock implements MapBloc {}

void main() {
  group('TourBloc', () {
    late TourBloc tourBloc;
    late MockOptimizationService mockOptimizationService;
    late MockEcoCityTourRepository mockEcoCityTourRepository;
    late MockMapBloc mockMapBloc;

    setUp(() {
      mockOptimizationService = MockOptimizationService();
      mockEcoCityTourRepository = MockEcoCityTourRepository();
      mockMapBloc = MockMapBloc();
      tourBloc = TourBloc(
        optimizationService: mockOptimizationService,
        ecoCityTourRepository: mockEcoCityTourRepository,
        mapBloc: mockMapBloc,
      );
    });

    tearDown(() {
      tourBloc.close();
    });

    test('initial state is TourState', () {
      expect(tourBloc.state, const TourState());
    });

    group('Event Handling', () {
      blocTest<TourBloc, TourState>(
        'emits [TourState] with isLoading true when LoadTourEvent is added',
        build: () => tourBloc,
        act: (bloc) => bloc.add(const LoadTourEvent(
            city: 'TestCity',
            numberOfSites: 5,
            systemInstruction: '',
            userPreferences: [],
            mode: '',
            maxTime: 90)),
        expect: () => [
          const TourState(isLoading: true),
        ],
      );

      blocTest<TourBloc, TourState>(
        'emits [TourState] with isJoined toggled when OnJoinTourEvent is added',
        build: () => tourBloc,
        act: (bloc) => bloc.add(const OnJoinTourEvent()),
        expect: () => [
          const TourState(isJoined: true),
        ],
      );

      blocTest<TourBloc, TourState>(
        'emits [TourState] with saved tours when LoadSavedToursEvent is added',
        build: () => tourBloc,
        act: (bloc) => bloc.add(const LoadSavedToursEvent()),
        expect: () => [
          const TourState(isLoading: true),
          isA<TourState>(),
        ],
      );

      blocTest<TourBloc, TourState>(
        'emits [TourState] with loaded tour when LoadTourFromSavedEvent is added',
        build: () => tourBloc,
        act: (bloc) =>
            bloc.add(const LoadTourFromSavedEvent(documentId: 'testId')),
        expect: () => [
          const TourState(isLoading: true),
          isA<TourState>(),
        ],
      );

      blocTest<TourBloc, TourState>(
        'emits [TourState] with reset state when ResetTourEvent is added',
        build: () => tourBloc,
        act: (bloc) => bloc.add(const ResetTourEvent()),
        expect: () => [
          const TourState(ecoCityTour: null, isJoined: false),
        ],
      );
    });
  });
}
