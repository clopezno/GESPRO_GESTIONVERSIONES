
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/helpers/helpers.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('createCircularImageWithBorder', () {
    test('devuelve Uint8List con imagen circular y borde', () async {
      final ByteData data = await rootBundle.load('assets/location_troll_bg2.png');
      final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo frameInfo = await codec.getNextFrame();

      final result = await createCircularImageWithBorder(frameInfo.image);

      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, true);
    });

    test('lanza una excepción si la imagen no se puede convertir', () async {
      // Crea una imagen inválida que provoca un fallo al intentar dibujarla
      final CorruptedImage corruptedImage = CorruptedImage();

      expect(
        () async => await createCircularImageWithBorder(corruptedImage),
        throwsA(isA<Exception>()),
      );
    });
  });
}

// Clase personalizada que simula una imagen corrupta
class CorruptedImage implements ui.Image {
  @override
  int get width => throw Exception('Error al obtener el ancho de la imagen.');

  @override
  int get height => throw Exception('Error al obtener el alto de la imagen.');

  @override
  void dispose() {}

  @override
  bool get debugDisposed => false;

  @override
  Future<ByteData?> toByteData({ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    throw Exception('Error al convertir la imagen a bytes.');
  }

  @override
  ui.Image clone() => throw Exception('Clone no soportado en CorruptedImage.');

  @override
  bool isCloneOf(ui.Image other) => throw Exception('isCloneOf no soportado en CorruptedImage.');

  @override
  List<StackTrace>? debugGetOpenHandleStackTraces() => null;

  @override
  ui.ColorSpace get colorSpace => throw Exception('ColorSpace no soportado en CorruptedImage.');
}
