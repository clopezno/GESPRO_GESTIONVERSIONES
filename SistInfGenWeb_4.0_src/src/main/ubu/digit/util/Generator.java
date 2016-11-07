package ubu.digit.util;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;

import org.apache.log4j.Logger;

import ubu.digit.htmlgen.DocCurrent;
import ubu.digit.htmlgen.DocHistoric;
import ubu.digit.htmlgen.DocIndex;
import ubu.digit.htmlgen.DocMetric;
import ubu.digit.htmlgen.DocSistInfHtml;

/**
 * Generación del portal de la asignatura de Sistemas Informáticos. Se puede
 * configurar el portal dependiendo del nivel de gestión que se lleve a cabo.
 * Este nivel ha de modificarse en el fichero de configuración.
 * <p>
 * Ejecutar la aplicación: "java -jar SistInfGenWeb.jar"
 * <p>
 * - nivel 1: Genera Tribunal, Calendario, Normas, Documentos utilizados
 * (index.html)
 * <p>
 * - nivel 2: Genera nivel 1 + asignación de proyectos en curso
 * (ActualesSist.html)
 * <p>
 * - nivel 3: Genera nivel 2 + histórico de proyectos y métricas de proceso
 * (HistoricoSist.html)
 * <p>
 * - nivel 4: Genera nivel 3 + métricas de productos (MetricSist.html);
 * <p>
 * - Por defecto se ejecuta nivel 4:");
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 0.6
 * @version 2.0
 */
public class Generator {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(Generator.class);

    private static GeneratorRSS generatorRSS;

    /**
     * URL donde encontramos el fichero con las propiedades del proyecto.
     */
    private static ExternalProperties prop = ExternalProperties
            .getInstance("./../src/main/config.properties");

    /**
     * Constructor vacío.
     */
    private Generator() {

    }

    /**
     * Generación del portal de la asignatura de Sistemas Informáticos. Se puede
     * configurar el portal dependiendo del nivel de gestión que se lleve a
     * cabo. Este nivel ha de modificarse en el fichero de configuración.
     * <p>
     * Ejecutar la aplicación: "java -jar SistInfGenWeb.jar"
     * <p>
     * - nivel 1: Genera Tribunal, Calendario, Normas, Documentos utilizados
     * (index.html)
     * <p>
     * - nivel 2: Genera nivel 1 + asignación de proyectos en curso
     * (ActualesSist.html)
     * <p>
     * - nivel 3: Genera nivel 2 + histórico de proyectos y métricas de proceso
     * (HistoricoSist.html)
     * <p>
     * - nivel 4: Genera nivel 3 + métricas de productos (MetricSist.html);
     * <p>
     * - Por defecto se ejecuta nivel 4:");
     * 
     * @param arg
     *            Nivel de generación.
     * @throws IOException
     */
    public static void main(String[] arg) throws IOException {

        try {

            String s = prop.getSetting("dirOut");
            generatorRSS = new GeneratorRSS(s
                    + "\\rss\\SistemasInformaticos.rss", "UTF-8");
            generatorRSS.generateChannelProperties();
        } catch (UnsupportedEncodingException e) {
            LOGGER.error(
                    "Fatal Error: El formato de codificación es incorrecto para generar RSS",
                    e);
        } catch (FileNotFoundException e) {
            LOGGER.error("Fatal Error: No puede generar el fichero RSS", e);
        }
        String value = prop.getSetting("nivel");
        if (String.valueOf(4).equals(value) || "".equals(value)) {
            createIndex(4);
            createActuales(4);
            createHistoric(4);
            createMetric(4);
        } else {
            if (String.valueOf(1).equals(value)) {
                createIndex(1);
            }
            if (String.valueOf(2).equals(value)) {
                createIndex(2);
                createActuales(2);
            }
            if (String.valueOf(3).equals(value)) {
                createIndex(3);
                createActuales(3);
                createHistoric(3);
            }
            if (String.valueOf(4).equals(value)) {
                createIndex(4);
                createActuales(4);
                createHistoric(4);
                createMetric(4);
            }

            if (("help").equals(value) || ("?").equals(value)) {
                imprimirInformacion();
            }
        }

        generatorRSS.generateFootRSSChannel();
        LOGGER.info("FIN.");
    }

    /**
     * Información de ayuda en línea. Se activa con ejecuciones desde línea de
     * consola con ? o help en el primer parámetro.
     */
    private static void imprimirInformacion() {

        LOGGER.info("\nEjecutar la aplicación: java -jar SistInfGenWeb.jar"
                + "\nDentro del fichero de configuración deberá asignar un nivel de gestión."
                + "\n\tnivel: es un entero comprendido entre [1,4] que indica el nivel de gestión"
                + "\n\t  - nivel 1: Genera index.html"
                + "\n\t  - nivel 2: Genera index.html,ActualesSist.html"
                + "\n\t  - nivel 3: Genera index.html,ActualesSist.html,HistoricoSist.html"
                + "\n\t  - nivel 4: Genera index.html,ActualesSist.html,HistoricoSist.html, MetricSist.html"
                + "\nPor defecto se ejecuta nivel 4.");
    }

    /**
     * Generación de MetricSist.html y asociación con el resto de documentos de
     * nivel 4.
     * 
     * @param level
     *            Información de nivel de gestión.
     */
    public static void createMetric(int level) {
        final String title = "Métricas de código e intervalos recomendados respecto a los trabajos presentados";
        final String link = "http://pisuerga.inf.ubu.es/lsi/Asignaturas/SI/MetricSist.html";
        String description = "Metricas de código independientes del lenguaje de programación e intervalos recomendados."
                + "Evaluación de trabajos presentados en la asignatura.";
        DocSistInfHtml docMetric;

        try {
            docMetric = new DocMetric();

            docMetric.generate(level);
            generatorRSS.generateItem("\t", title, link, description);
            LOGGER.info("* - Metric generado correctamente        *");
        } catch (SQLException e) {

            LOGGER.error(
                    "Posibles errores"
                            + "\n1.- Estructura de tablas, comprobar nombres, mayúsculas, minúsculas, espacios en blanco, formato numeros decimales separados por '.'"
                            + "\n\t Todos los datos son de tipo String."
                            + "\n\t\t1.1- DescripcionExperimento[Descripcion]"
                            + "\n\t\t1.2- MetricaDescripcion[Descripcion,Id,Tipo,MinValor,MaxValor,Visible]"
                            + "\n\t\t1.3- MetricaValores(M0,M1,M2,M3,J0,J1,J2,J3,J4, J5, J6, J7, J8, J9, J10, J11, J12, J13, J14, D0, D1, D2, D3, D4, D5, D6, D7, D8, D9) "
                            + "\n\t\t--- Se corresponden con los valores de las filas del campo Id de MetricaDescripcion---",
                    e);
        } catch (FileNotFoundException e) {
            LOGGER.error(
                    "Posibles errores"
                            + "\n1.- Existe una carpeta ./web colgando del directorio actual"
                            + "\n2.- Problemas de apertura de fichero"
                            + "\n\t\t2.1- Existe espacio en el disco"
                            + "\n\t\t2.2- Esta la carpeta web protegida contra escritura"
                            + "\n\t\t2.3- Existe un fichero MetricSist.html y esta protegido ",
                    e);
        }
    }

    /**
     * Generación de HistoricoSist.html y asociación con el resto de documentos
     * de nivel 3.
     * 
     * @param level
     *            Información de nivel de gestión.
     */
    public static void createHistoric(int level) {
        final String title = "Histórico de trabajos presentados";
        final String link = "http://pisuerga.inf.ubu.es/lsi/Asignaturas/SI/HistoricoSist.html";
        String description = "Metricas del proceso de evaluación e históricos de trabajos presentados ";
        DocSistInfHtml docHistoric = new DocHistoric();

        try {
            docHistoric.generate(level);
            generatorRSS.generateItem("\t", title, link, description);
            LOGGER.info("* - Historico generado correctamente        *");
        } catch (FileNotFoundException e) {
            LOGGER.error(
                    "Posibles errores"
                            + "\n1.- Existe una carpeta ./web colgando del directorio actual"
                            + "\n2.- Problemas de apertura de fichero"
                            + "\n\t\t2.1- Existe espacio en el disco"
                            + "\n\t\t2.2- Esta la carpeta web protegida contra escritura"
                            + "\n\t\t2.3- Existe un fichero HistoricoSist.html y esta protegido ",
                    e);
        } catch (SQLException e) {
            LOGGER.error(
                    "Posibles errores"
                            + "\n1.- Estructura de tablas, comprobar nombres, mayúsculas, minúsculas, espacios en blanco, formato numeros decimales separados por '.'"
                            + "\n\t Todos los datos son de tipo String."
                            + "\n\t\t1.1- Historico[Titulo,Descripcion,Tutor1,Tutor2,Tutor3,Alumno1,Alumno2,Alumno3,FechaAsignacion,FechaPresentacion,Nota,TotalDias]",
                    e);
        }
    }

    /**
     * Generación de ActualesSist.html y asociación con el resto de documentos
     * de nivel 2.
     * 
     * @param level
     *            Información de nivel de gestión.
     */
    public static void createActuales(int level) {
        final String title = "Oferta de trabajos en curso";
        final String link = "http://pisuerga.inf.ubu.es/lsi/Asignaturas/SI/ActualesSist.html";
        String description = "Métricas del proceso de asignación y ofertas de trabajos de la asignatura";
        DocSistInfHtml docCurrent = new DocCurrent();

        try {
            docCurrent.generate(level);
            generatorRSS.generateItem("\t", title, link, description);
            LOGGER.info("* - Actuales generado correctamente        *");
        } catch (FileNotFoundException e) {
            LOGGER.error(
                    "Posibles errores"
                            + "\n1.- Existe una carpeta ./web colgando del directorio actual"
                            + "\n2.- Problemas de apertura de fichero"
                            + "\n\t\t2.1- Existe espacio en el disco"
                            + "\n\t\t2.2- Esta la carpeta web protegida contra escritura"
                            + "\n\t\t2.3- Existe un fichero ActualesSist.html y esta protegido",
                    e);
        } catch (SQLException e) {

            LOGGER.error(
                    "Posibles errores"
                            + "\n1.- Estructura de tablas, comprobar nombres, mayúsculas, minúsculas, espacios en blanco, formato numeros decimales separados por '.'"
                            + "\n\t Todos los datos son de tipo String."
                            + "\n\t\t1.1- Alumno[Numero,ApellidosNombre,Dni,Repetidor,Asignado]"
                            + "\n\t\t1.2- Proyecto[Titulo,Descripcion,Tutor1,Tutor2,Tutor3,Alumno1,Alumno2,Alumno3,CursoAsignacion]",
                    e);
        }
    }

    /**
     * Generación de index.html y asociación con el resto de documentos de nivel
     * 1.
     * 
     * @param level
     *            Información de nivel de gestión.
     */
    public static void createIndex(int level) {
        final String title = "Organización de la Asignatura";
        final String link = "http://pisuerga.inf.ubu.es/lsi/Asignaturas/SI/index.html";
        String description = "Miembros del tribunal, especificaciones de entrega, fechas de entrega, documentos";
        DocSistInfHtml docIndex = new DocIndex();

        try {
            docIndex.generate(level);
            generatorRSS.generateItem("\t", title, link, description);
            LOGGER.info("* - Index generado correctamente        *");
        } catch (FileNotFoundException e) {
            LOGGER.error(
                    "Posibles errores"
                            + "\n1.- Existe una carpeta ./web colgando del directorio actual"
                            + "\n2.- Problemas de apertura de fichero"
                            + "\n\t\t2.1- Existe espacio en el disco"
                            + "\n\t\t2.2- Esta la carpeta web protegida contra escritura"
                            + "\n\t\t2.3- Existe un fichero index.html y esta protegido",
                    e);
        } catch (SQLException e) {

            LOGGER.error(
                    "Posibles errores"
                            + "\n1.- Estructura de tablas, comprobar nombres, mayúsculas, minúsculas, espacios en blanco, formato numeros decimales separados por '.'"
                            + "\n\t Todos los datos son de tipo String."
                            + "\n\t\t1.1- Calendario[Descripcion,Convocatoria,Fecha"
                            + "\n\t\t1.2- Documento[Descripcion,Url]"
                            + "\n\t\t1.3- Norma[Descripcion]"
                            + "\n\t\t1.4- Tribunal[Cargo,NombreApellidos,Nick]",
                    e);
        }
    }

}
