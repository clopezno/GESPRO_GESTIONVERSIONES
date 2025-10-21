import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// Un AppBar personalizado para la pantalla de selección de tour.
///
/// Este AppBar incluye:
/// - Un título central: "Eco City Tours".
/// - Un botón de información que abre el wiki de la aplicación.
/// - Un menú desplegable para cambiar el idioma con banderas.
///
/// Este widget implementa [PreferredSizeWidget] para ser compatible con [AppBar].
class CustomSelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Constructor para [CustomSelectionAppBar].
  const CustomSelectionAppBar({super.key});

  /// Define la altura preferida del AppBar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Construye el AppBar con sus elementos.
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Eco City Tours',
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      automaticallyImplyLeading: false, // Oculta el botón de retroceso
      actions: [
        /// Botón para abrir el wiki de la aplicación.
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          tooltip: 'Ir al Wiki de la Aplicación',
          onPressed: () => _launchWikiURL(context),
        ),

        /// Menú desplegable para cambiar el idioma con banderas.
        PopupMenuButton<Locale>(
          icon: const Icon(Icons.language),
          tooltip: 'Cambiar idioma',
          onSelected: (Locale locale) {
            context.setLocale(locale);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: const Locale('en'),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/flags/gb.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('English'),
                ],
              ),
            ),
            PopupMenuItem(
              value: const Locale('es'),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/flags/es.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('Español'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Abre la URL del wiki en el navegador predeterminado.
  ///
  /// Si no se puede abrir la URL, muestra un [SnackBar] con un mensaje de error.
  Future<void> _launchWikiURL(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/fps1001/TFGII_FPisot/wiki');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace al Wiki')),
        );
      }
    }
  }
}
