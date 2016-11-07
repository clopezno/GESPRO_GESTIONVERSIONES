package ubu.digit.htmlgen;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintStream;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.util.Date;
import java.util.StringTokenizer;

import org.apache.log4j.Logger;

import ubu.digit.pesistence.SistInfData;
import ubu.digit.util.ExternalProperties;

/**
 * Clase abstracta que genera el conjunto de funcionalidad común a todas las
 * páginas del mismo portal de gestión de proyectos. Cabeceras y pie de páginas
 * comunes, menus, sistemas de trazabilidad web. También obtiene una instancia
 * una instancia de una fachada para acceder a los datos externos de proyectos.
 * <p>
 * Define un método abstracto para generar el cuerpo de las páginas.
 * <p>
 * Dependencias sobre recursos web: las páginas dependen de los ficheros
 * contenidos en el directorio ./css y ./js
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 0.5
 * @version 2.0
 */
public abstract class DocSistInfHtml {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(DocHistoric.class);

    /**
     * Variable que accede a la fachada para obtener los datos que necesitamos
     * de la base de datos.
     */
    protected SistInfData fachData;

    /**
     * Archivo de salida.
     */
    protected PrintStream outHtml;

    /**
     * Formato de los números.
     */
    protected NumberFormat numberFormat;

    /**
     * Variable que tiene la ISO que tiene la página web.
     */
    protected static final String CHARSET = "UTF-8";

    /**
     * URL donde encontramos el fichero con las propiedades del proyecto.
     */
    private static ExternalProperties prop = ExternalProperties
            .getInstance("./../src/main/config.properties");

    /**
     * Directorio de salida de los HTML creados.
     */
    private static final String DIROUT = prop.getSetting("dirOut");

    /**
     * URl de la ruta donde se encuentra el javascript de google analitics.
     */
    protected static final String WEB_JS_GOOGLEANALITICS_JS = DIROUT
            + "\\js\\googleanalitics.js";

    /**
     * URl de la ruta donde se encuentra el javascript de addThis.
     */
    protected static final String WEB_JS_ADDTHIS_JS = DIROUT
            + "\\js\\addThis.js";

    /**
     * URl de la ruta donde se encuentra el javascript de google translate.
     */
    protected static final String WEB_JS_GOOGLETRANSLATE_JS = DIROUT
            + "\\js\\google_translate.js";

    protected static final String STR_WARN_TABLE_ORDENABLE = "\t\t\t\t\t\t<ol class='lnorm'><li> Tabla ordenable por columnas. Haz click en las cabeceras de las columnas. </li></ol>";

    /**
     * Inicializa una instancia a una fachada para acceder a los datos del
     * sistema de almacenamiento persistente. Inicializa el formato de números
     * decimales.
     */
    public DocSistInfHtml() {
        fachData = SistInfData.getInstance();
        numberFormat = NumberFormat.getInstance();
        numberFormat.setMaximumFractionDigits(new Integer(2));
    }

    /**
     * Genera el contenido variable de las páginas html del mismo portal.
     * 
     * @param level
     *            Nivel de gestión empleado.
     */
    public abstract void generate(int level) throws FileNotFoundException,
            SQLException;

    /**
     * Genera el código html correspondiente a un menu de una dimensión cuyos
     * títulos se pasan como parámetro.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css.
     * <p>
     * Añade un enlace de difusión de la página mediante marcadores dinámicos, y
     * invocacción al serviccio de traducción al inglés de google.
     * 
     * @param pagina
     *            Página de la que se va a hacer la referencia.
     * 
     * @param menuItems
     *            Títulos de los campos del menú.
     */
    protected void createInterMenu(String pagina, String[] menuItems) {
        for (String item : menuItems) {
            String firstToken;
            StringTokenizer tokenizer = new StringTokenizer(item, " ", false);
            firstToken = tokenizer.nextToken();
            outHtml.println("\t\t\t\t\t\t<li><a href='" + pagina + "#"
                    + firstToken + "'>" + item + "</a></li>");
        }
    }

    /**
     * Genera un pie de página html con la fecha actual de actualización y los
     * iconos de validación W3C.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css.
     */
    protected void createFootHtml() {
        long segTotal = System.currentTimeMillis();
        Date date = new Date(segTotal);

        outHtml.println("\t\t\t<footer class='page-footer grey ubu'>");

        outHtml.println("\t\t\t\t<div class='container'>");
        outHtml.println("\t\t\t\t\t<div class='row'>");

        outHtml.println("\t\t\t\t\t\t<div class='col l4 s12'>");
        outHtml.println("\t\t\t\t\t\t\t<h5 class='white-text'>Informaci&oacute;n</h5>");
        outHtml.println("\t\t\t\t\t\t\t<p class='white-text'><i class='mdi-action-face-unlock'></i> Creado por <strong>Beatriz Zurera Mart&iacute;nez-Acitores</strong> <br/>");
        outHtml.println("\t\t\t\t\t\t\t<i class='mdi-communication-email'></i> <a href='mailto:bzm0001@alu.ubu.es'>bzm0001@alu.ubu.es</a> </p>");
        outHtml.println("\t\t\t\t\t\t\t<p class='white-text'><i class='mdi-hardware-keyboard-alt'></i> Tutorizado por <strong>Carlos L&oacute;pez Nozal </strong> <br/>");
        outHtml.println("\t\t\t\t\t\t\t<i class='mdi-communication-email'></i> <a href='mailto:clopezno@ubu.es'>clopezno@ubu.es</a> </p>");
        outHtml.println("\t\t\t\t\t\t</div>");

        outHtml.println("\t\t\t\t\t\t<div class='col l4 s12'>");
        outHtml.println("\t\t\t\t\t\t\t<ul>");
        outHtml.println("\t\t\t\t\t\t\t\t<li><a href='http://validator.w3.org/check/referer' title='UBU'><img class='img-responsive' src='./images/HTML.png' title='UBU' alt='UBU'/></a></li>");
        outHtml.println("\t\t\t\t\t\t\t</ul>");
        outHtml.println("\t\t\t\t\t\t</div>");

        outHtml.println("\t\t\t\t\t\t<div class='col l4 s12'>");
        outHtml.println("\t\t\t\t\t\t\t<ul>");
        outHtml.println("\t\t\t\t\t\t\t\t<li class='white-text'><a rel='license' href='http://creativecommons.org/licenses/by/4.0/'><img alt='Creative Commons License' style='border-width:0' src='https://i.creativecommons.org/l/by/4.0/88x31.png' /></a><br />SistInfWeb by Carlos L&oacute;pez Nozal and Beatriz Zurera Mart&iacute;nez-Acitores is licensed under a <a rel='license' href='http://creativecommons.org/licenses/by/4.0/'>Creative Commons Attribution 4.0 International License</a>.</li>");
        outHtml.println("\t\t\t\t\t\t\t\t<li class='white-text'>Fecha de actualizaci&oacute;n "
                + date.toString() + " </li>");
        outHtml.println("\t\t\t\t\t\t\t</ul>");
        outHtml.println("\t\t\t\t\t\t</div>");
        outHtml.println("\t\t\t\t\t</div>");
        outHtml.println("\t\t\t\t</div>");
        outHtml.println("\t\t\t\t<div class='footer-copyright'>");
        outHtml.println("\t\t\t\t\t<div class='container white-text'>");
        outHtml.println("\t\t\t\t\t\tCopyright  <strong>&copy; LSI</strong>.");
        outHtml.println("\t\t\t\t\t</div>");

        outHtml.println("\t\t\t\t</div>");
        outHtml.println("\t\t\t</footer>");
    }

    /**
     * Genera el código html para incluir un script contenido en un fichero.
     * 
     * @param scriptFileName
     *            Nombre del fichero que contiene el script a incorporar en la
     *            página html.
     * @param tabs
     *            Secuencia inicial de tabuladores para el formateo de la página
     *            html.
     */
    protected void createScript(String scriptFileName, String tabs) {

        try {
            BufferedReader fInHtmlCodeScript = new BufferedReader(
                    new FileReader(scriptFileName));
            String line;
            while ((line = fInHtmlCodeScript.readLine()) != null) {
                outHtml.println(tabs + line);
            }
            fInHtmlCodeScript.close();

        } catch (FileNotFoundException e) {
            LOGGER.error("*** Error: No se puede abrir el fichero: "
                    + scriptFileName, e);
            LOGGER.error("*** Las páginas web se generarán correctamente "
                    + "pero sin sistema de análisis de accesos y difusion", e);
        } catch (IOException e) {
            LOGGER.error("*** Error: No se puede abrir el fichero: "
                    + scriptFileName, e);
            LOGGER.error("*** Las páginas web se generarán correctamente "
                    + "pero sin sistema de análisis de accesos y difusion", e);
        }
    }

    /**
     * Genera el código html correspondiente a la cabecera html.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css, ./images/logoLSI.gif,
     * ./js/sorttable.js.
     * 
     * @param title
     *            Título de la página html.
     */
    protected void createHeaderHtml(String title) {

        outHtml.println("\t\t<meta charset='UTF-8'/>");
        outHtml.println("\t\t<meta name='description' content='Informaci&oacute;n sobre los proyectos final de carrera "
                + " presentados en 5º de Ingenier&iacute;a Inform&aacute;tica en la Universidad de Burgos' />");
        outHtml.println("\t\t<meta name='keywords' content='Sistemas Inform&aacute;ticos, m&eacute;tricas software, "
                + "ingenieria software, proyectos inform&aacute;ticos'/>");
        outHtml.println("\t\t<title> " + title + " </title>");
        outHtml.println("\t\t<link rel='shortcut icon' href='./images/logoLSI.gif'/>");

        outHtml.println("\t\t<script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>");

        outHtml.println("\t\t<link rel='alternate' title='Sistemas Informaticos' href='./rss/SistemasInformaticos.rss' type='application/rss+xml' />");
        outHtml.println("\t\t<!--JS-->");
        outHtml.println("\t\t<script src='https://code.jquery.com/jquery-2.1.1.min.js'></script>");
        outHtml.println("\t\t<script src='./js/materialize.min.js' type='text/javascript'> </script>");
        outHtml.println("\t\t<script src='./js/init.js' type=\"text/javascript\"> </script>");
        outHtml.println("\t\t<script src='./js/sorttable.js' type='text/javascript'> </script>");
        outHtml.println("\t\t<script src='./js/chart.js' type=\"text/javascript\"> </script>");

        outHtml.println("\t\t<!--CSS-->");
        outHtml.println("\t\t<link href='css/materialize.min.css' type='text/css' rel='stylesheet' media='screen,projection'/>");
        outHtml.println("\t\t<link href='css/style.css' type='text/css' rel='stylesheet' media='screen,projection'/>");
    }

    /**
     * Genera el código html correspondiente a un tab_menu de una dimensión. Las
     * referencias del menú se corresponde con la estructura de las páginas que
     * componen el portal.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css
     * 
     * @param level
     *            Nivel de generación del portal.
     * @throws SQLException
     * 
     */
    protected void createMenuHtml(int level) throws SQLException {
        outHtml.println("\t\t\t\t<header>");

        outHtml.println("\t\t\t\t\t<nav class='red ubu'>");
        outHtml.println("\t\t\t\t\t\t<div class='container'>");
        outHtml.println("\t\t\t\t\t\t\t<div class='nav-wrapper'>");
        outHtml.println("\t\t\t\t\t\t\t\t<div class='col s12'>");
        String logoUBU = prop.getSetting("logoUBU");
        if ("".equals(logoUBU)) {
            logoUBU = "./images/logoUBU.png";
        }
        outHtml.println("\t\t\t\t\t\t\t\t\t<a href='index.html' class='brand-logo'><img src='"
                + logoUBU + "' alt='UBu'/></a>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<ul class='right hide-on-med-and-down'>");
        switch (level) {
        case 1:
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button'>Informaci&oacute;n</a></li>");
            break;
        case 2:
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='index.html'>Informaci&oacute;n</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='ActualesSist.html'>Proyectos activos</a></li>");
            break;
        case 3:
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='index.html'>Informaci&oacute;n</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='ActualesSist.html'>Proyectos activos</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='HistoricoSist.html'>Hist&oacute;rico</a></li>");
            break;
        case 4:
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='index.html'>Informaci&oacute;n</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='ActualesSist.html'>Proyectos activos</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='HistoricoSist.html'>Hist&oacute;rico</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a class='dropdown-button' href='MetricSist.html'>M&eacute;tricas</a></li>");
            break;
        default:
            break;
        }
        outHtml.println("\t\t\t\t\t\t\t\t\t</ul>");

        outHtml.println("\t\t\t\t\t\t\t\t\t<ul id='slide-out' class='side-nav full'>");
        switch (level) {
        case 1:
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='index.html'>Informaci&oacute;n</a></li>");
            break;
        case 2:
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='index.html'>Informaci&oacute;n</a></li>");
            outHtml.println("\t\t\t\t\t\t\t<li><a href='ActualesSist.html'>Proyectos activos</a></li>");
            break;
        case 3:
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='index.html'>Informaci&oacute;n</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='ActualesSist.html'>Proyectos activos</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='HistoricoSist.html'>Hist&oacute;rico</a></li>");
            break;
        case 4:
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='index.html'>Informaci&oacute;n</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='ActualesSist.html'>Proyectos activos</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='HistoricoSist.html'>Hist&oacute;rico</a></li>");
            outHtml.println("\t\t\t\t\t\t\t\t\t\t<li><a href='MetricSist.html'>M&eacute;tricas</a></li>");
            break;
        default:
            break;
        }
        outHtml.println("\t\t\t\t\t\t\t\t\t</ul>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<a href='#' data-activates='slide-out' class='button-collapse'><i class='mdi-navigation-menu'></i></a>");
        outHtml.println("\t\t\t\t\t\t\t\t</div>");
        outHtml.println("\t\t\t\t\t\t\t</div>");
        outHtml.println("\t\t\t\t\t\t</div>");
        outHtml.println("\t\t\t\t\t</nav>");
        outHtml.println("\t\t\t\t</header>");
        outHtml.println("\t\t\t\t<div id='pageHome' class='container'>");
        outHtml.println("\t\t\t\t\t<section>");
        outHtml.println("\t\t\t\t\t\t<div class='container right_aligned'>");
        createScript(WEB_JS_ADDTHIS_JS, "\t\t\t\t\t\t\t");
        createScript(WEB_JS_GOOGLETRANSLATE_JS, "\t\t\t\t\t\t\t");
        outHtml.println("\t\t\t\t\t\t</div>");
        outHtml.println("\t\t\t\t\t</section>");

    }

    /**
     * Genera el código html correspondiente a la cabecera de una tabla html con
     * un icono.
     * 
     * @param columnNames
     *            Nombre de las columnas.
     * @param icoTable
     *            Referencia del icono que se quiere añadir a la tabla.
     * @param columnToolTip
     *            Texto de ayuda a visualizar cuando el ratón pase poe encima.
     */
    protected void createHeaderTable(String[] columnNames, String icoTable,
            String tam, String[] columnToolTip) {
        outHtml.println("\t\t\t\t\t\t\t<thead>");
        outHtml.println("\t\t\t\t\t\t\t\t<tr>");

        // Calculate colspan
        if (columnNames.length > 1) {
            if ("".equals(columnNames[1])) {
                outHtml.println("\t\t\t\t\t\t\t\t\t<th colspan='"
                        + columnNames.length + "'> <i class='" + tam + " "
                        + icoTable + "'></i>" + columnNames[0] + "</th>");
            } else {
                outHtml.println("\t\t\t\t\t\t\t\t\t<th> " + columnNames[0]
                        + "<i class= ' " + tam + " " + icoTable + "'></i></th>");
                for (int index = 1; index < columnNames.length; index++) {
                    if (columnToolTip != null) {
                        outHtml.println("\t\t\t\t\t\t\t\t\t<th onmouseover=\"Tip('"
                                + columnToolTip[index]
                                + "')\" onmouseout=\"UnTip()\">"
                                + columnNames[index] + "</th>");
                    } else {
                        outHtml.println("\t\t\t\t\t\t\t\t\t<th> "
                                + columnNames[index] + "</th>");
                    }

                }
            }
        }
        if (columnNames.length == 1) {
            outHtml.println("\t\t\t\t\t\t\t\t\t<th> <i class=' " + tam + " "
                    + icoTable + "'></i>" + columnNames[0] + "</th>");
        }

        outHtml.println("\t\t\t\t\t\t\t\t</tr> ");
        outHtml.println("\t\t\t\t\t\t\t</thead>");
    }

    /**
     * Genera el código html correspondiente a un menu de índices para navegar
     * en una tabla html. La tabla html puede se página respecto al número de
     * filas.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css ./js/sorttable.js
     * 
     * @param tamPage
     *            Número de filas por página.
     * @param totalEntry
     *            Número total filas.
     * @param prefix
     *            Caracter para identificar las filas de la tabla en html.
     *            Deberá ser distinto si existen varias filas en la misma tabla.
     */
    protected void createPageIndex(int tamPage, int totalEntry, char prefix) {
        // Indices de paginas
        outHtml.println("\t\t\t\t\t\t<p></p>");
        outHtml.println("\t\t\t\t\t\t<table class='nav'>");
        outHtml.println("\t\t\t\t\t\t\t<tbody>");
        outHtml.println("\t\t\t\t\t\t\t\t<tr>");

        int nPag = totalEntry / tamPage;
        outHtml.println("\t\t\t\t\t\t\t\t\t<td><a href=\"javascript:MostrarAllFilas("
                + totalEntry + ", '" + prefix + "')\"> Todas</a> </td>");

        int rangoInf = 1;
        for (int j = 0; j <= nPag - 1; j++) {
            int rangoSup = (j * tamPage) + tamPage;
            outHtml.println("\t\t\t\t\t\t\t\t\t<td><a href=\"javascript:MostrarFilas("
                    + j
                    + ','
                    + tamPage
                    + ','
                    + totalEntry
                    + ", '"
                    + prefix
                    + "')\">" + rangoInf + "..." + rangoSup + "</a> </td>");
            rangoInf += tamPage;
        }
        int nEntryLastPage = totalEntry % tamPage;
        if (nEntryLastPage != 0) {
            rangoInf = (nPag * tamPage) + 1;
            int rangoSup = rangoInf - 1 + nEntryLastPage;
            outHtml.println("\t\t\t\t\t\t\t\t\t<td><a href=\"javascript:MostrarFilasUltima("
                    + nPag
                    + ','
                    + nEntryLastPage
                    + ','
                    + tamPage
                    + ','
                    + totalEntry
                    + ", '"
                    + prefix
                    + "')\">"
                    + rangoInf
                    + "..."
                    + rangoSup + "</a> </td>");

        }
        outHtml.println("\t\t\t\t\t\t\t\t</tr>");
        outHtml.println("\t\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t</table>");
        outHtml.println("\t\t\t\t\t\t<p></p>");

    }

    /**
     * Genera el código html correspondiente a un título dentro del cuerpo del
     * página html. Se una refencia de acceso interna a la propia página, asi
     * como una refencia al inicio de la página.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css
     * 
     * @param title
     *            Contenido del título.
     */
    protected void createSubTitleMenu(String title) {

        outHtml.println("\t\t\t\t\t\t<h2 class='leading_line left_aligned'>"
                + title
                + "<a href='#top'><i class='mdi-navigation-expand-less small'></i></a>");
        outHtml.println("\t\t\t\t\t\t</h2>");

    }
}
