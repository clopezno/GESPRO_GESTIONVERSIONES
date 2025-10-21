import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/blocs/location/location_bloc.dart';

class MockLocationBloc extends LocationBloc {
  final List<LatLng> mockPositions;

  MockLocationBloc({required this.mockPositions});

  @override
  Future<LatLng> getCurrentPosition() async {
    return mockPositions.first; // Devuelve la primera posición simulada
  }

  @override
  void startFollowingUser() {
    if (!isClosed) {
      add(const OnStartFollowingUser());
      for (final position in mockPositions) {
        add(OnNewUserLocationEvent(position));
      }
    }
  }

  @override
  void stopFollowingUser() {
    if (!isClosed) {
      add(const OnStopFollowingUser());
    }
  }
}

void main() {
  late MockLocationBloc mockLocationBloc;

  setUp(() {
    mockLocationBloc = MockLocationBloc(
      mockPositions: [
        const LatLng(37.7749, -122.4194),
        const LatLng(37.7750, -122.4195),
      ],
    );
  });

  tearDown(() async {
    await mockLocationBloc.close();
  });

  group('LocationBloc', () {
    test('Initial state is correct', () {
      expect(
        mockLocationBloc.state,
        const LocationState(
          followingUser: false,
          lastKnownLocation: null,
          myLocationHistory: <LatLng>[],
        ),
      );
    });

    blocTest<MockLocationBloc, LocationState>(
      'Emits new location when OnNewUserLocationEvent is added',
      build: () => mockLocationBloc,
      act: (bloc) =>
          bloc.add(const OnNewUserLocationEvent(LatLng(37.7749, -122.4194))),
      expect: () => [
        const LocationState(
          followingUser: false,
          lastKnownLocation: LatLng(37.7749, -122.4194),
          myLocationHistory: <LatLng>[LatLng(37.7749, -122.4194)],
        ),
      ],
    );

    
    blocTest<MockLocationBloc, LocationState>(
      'Stops following user without emitting redundant states',
      build: () => mockLocationBloc,
      act: (bloc) => bloc.stopFollowingUser(),
      expect: () => [
        const LocationState(followingUser: false), // Detiene seguimiento
      ],
    );

    test('getCurrentPosition returns the correct location', () async {
      final position = await mockLocationBloc.getCurrentPosition();
      expect(
        position,
        const LatLng(37.7749, -122.4194),
      );
    });
  });
}
