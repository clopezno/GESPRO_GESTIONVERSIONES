import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:project_app/blocs/gps/gps_bloc.dart';

class MockGpsService {
  Future<bool> isGpsEnabled() async {
    // Simulación del estado inicial del GPS
    return true; // Cambia a `false` para probar otros escenarios
  }

  Stream<bool> get gpsStatusStream async* {
    // Simulación de cambios en el estado del GPS
    yield true;  // GPS habilitado
    await Future.delayed(const Duration(milliseconds: 500));
    yield false; // GPS deshabilitado
  }

  Future<bool> isPermissionGranted() async {
    // Simulación del estado inicial de los permisos
    return true; // Cambia a `false` para probar otros escenarios
  }

  Future<bool> requestPermission() async {
    // Simulación del resultado al solicitar permisos
    return true; // Cambia a `false` para probar permisos denegados
  }
}

void main() {
  late GpsBloc gpsBloc;
  late MockGpsService mockGpsService;

  setUp(() {
    mockGpsService = MockGpsService();
    gpsBloc = GpsBloc(); // Sin modificar el Bloc original.
  });

  tearDown(() async {
    await gpsBloc.close();
  });

  group('GpsBloc', () {
    blocTest<GpsBloc, GpsState>(
      'Verifica el estado inicial del GpsBloc',
      build: () => gpsBloc,
      verify: (bloc) {
        expect(
          bloc.state,
          const GpsState(
              isGpsEnabled: false, isGpsPermissionGranted: false),
        );
      },
    );

    blocTest<GpsBloc, GpsState>(
      'Simula que GPS está habilitado y permisos están concedidos',
      build: () => gpsBloc,
      act: (bloc) async {
        // Simular evento usando los métodos mock
        bloc.add(OnGpsAndPermissionEvent(
          isGpsEnabled: await mockGpsService.isGpsEnabled(),
          isGpsPermissionGranted: await mockGpsService.isPermissionGranted(),
        ));
      },
      expect: () => [
        const GpsState(isGpsEnabled: true, isGpsPermissionGranted: true),
      ],
    );

    blocTest<GpsBloc, GpsState>(
      'Simula cambios en el estado del GPS',
      build: () => gpsBloc,
      act: (bloc) async {
        await for (final status in mockGpsService.gpsStatusStream) {
          bloc.add(OnGpsAndPermissionEvent(
            isGpsEnabled: status,
            isGpsPermissionGranted: gpsBloc.state.isGpsPermissionGranted,
          ));
        }
      },
      expect: () => [
        const GpsState(isGpsEnabled: true, isGpsPermissionGranted: false),
        const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
      ],
    );

    blocTest<GpsBloc, GpsState>(
      'Simula solicitud de permisos',
      build: () => gpsBloc,
      act: (bloc) async {
        final granted = await mockGpsService.requestPermission();
        bloc.add(OnGpsAndPermissionEvent(
          isGpsEnabled: gpsBloc.state.isGpsEnabled,
          isGpsPermissionGranted: granted,
        ));
      },
      expect: () => [
        const GpsState(isGpsEnabled: false, isGpsPermissionGranted: true),
      ],
    );
  });
}
