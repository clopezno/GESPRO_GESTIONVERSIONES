import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

/// Obtiene un marcador personalizado a partir de una imagen local.
///
/// La imagen se redimensiona a un tamaño específico antes de ser convertida
/// en un objeto [BitmapDescriptor].
///
/// Retorna un marcador personalizado o el marcador predeterminado en caso de error.
Future<BitmapDescriptor> getCustomMarker() async {
  try {
    final ByteData data =
        await rootBundle.load('assets/location_troll_bg2.png');
    final ui.Codec imageCodec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: 62,
      targetWidth: 45,
    );
    final ui.FrameInfo frameInfo = await imageCodec.getNextFrame();
    final ByteData? resizedData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

    if (resizedData == null) {
      log.e('getCustomMarker: Error al convertir la imagen a bytes.');
      return BitmapDescriptor.defaultMarker;
    }

    log.d('getCustomMarker: Marcador personalizado creado con éxito.');
    return BitmapDescriptor.bytes(resizedData.buffer.asUint8List());
  } catch (e, stackTrace) {
    log.e('getCustomMarker: Error al cargar el marcador personalizado',
        error: e, stackTrace: stackTrace);
    return BitmapDescriptor.defaultMarker;
  }
}

/// Obtiene un marcador personalizado desde una imagen de red.
///
/// Descarga la imagen desde una URL, la procesa para que sea compatible
/// con Google Maps, y la convierte en un marcador personalizado.
/// Si ocurre un error, retorna un marcador predeterminado.
///
/// - [imageUrl]: URL de la imagen que se usará para el marcador.
Future<BitmapDescriptor> getNetworkImageMarker(String imageUrl) async {
  try {
    Uri uri = Uri.parse(imageUrl);
    if (!uri.isAbsolute) {
      log.w(
          'getNetworkImageMarker: URL inválida, usando marcador predeterminado.');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    final response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    if (response.statusCode != 200 || response.data == null) {
      log.e(
          'getNetworkImageMarker: Fallo al descargar imagen, usando marcador predeterminado.');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    final codec = await ui.instantiateImageCodec(response.data,
        targetHeight: 40, targetWidth: 40);
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    final markerBytes = await createCircularImageWithBorder(image);
    log.d(
        'getNetworkImageMarker: Marcador con imagen de red creado con éxito.');
    return BitmapDescriptor.bytes(markerBytes);
  } catch (e, stackTrace) {
    log.e('getNetworkImageMarker: Error al cargar imagen desde la red',
        error: e, stackTrace: stackTrace);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }
}

/// Crea una imagen circular con un borde alrededor.
///
/// - [image]: Imagen original que se transformará en un círculo.
/// - [borderColor]: Color del borde (por defecto, verde).
/// - [borderWidth]: Grosor del borde (por defecto, 4).
///
/// Retorna un [Uint8List] con la imagen transformada o lanza una excepción
/// en caso de error.
Future<Uint8List> createCircularImageWithBorder(ui.Image image,
    {Color borderColor = Colors.green, double borderWidth = 4}) async {
  try {
    log.d(
        'createCircularImageWithBorder: Iniciando creación de imagen circular.');

    final double imageSize = image.width.toDouble();
    final double size = imageSize + borderWidth * 2;

    log.d(
        'createCircularImageWithBorder: Dimensiones calculadas. Tamaño: $size');

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final center = Offset(size / 2, size / 2);
    final radius = imageSize / 2;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    log.d('createCircularImageWithBorder: Dibujando el círculo de borde.');

    canvas.drawCircle(center, radius + borderWidth, borderPaint);

    final Rect imageRect = Rect.fromCircle(center: center, radius: radius);
    canvas.clipPath(Path()..addOval(imageRect));
    canvas.drawImage(image, imageRect.topLeft, Paint());

    log.d('createCircularImageWithBorder: Imagen dibujada sobre el lienzo.');

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      log.e(
          'createCircularImageWithBorder: Fallo al convertir la imagen a bytes.');
      throw Exception('Error al convertir la imagen a bytes.');
    }

    log.d('createCircularImageWithBorder: Imagen circular creada con éxito.');

    return byteData.buffer.asUint8List();
  } catch (e, stackTrace) {
    log.e(
        'createCircularImageWithBorder: Error durante la creación de la imagen circular.',
        error: e,
        stackTrace: stackTrace);
    throw Exception('Error al crear imagen circular: $e');
  }
}
