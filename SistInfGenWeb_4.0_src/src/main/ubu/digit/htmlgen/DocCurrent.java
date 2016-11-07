package ubu.digit.htmlgen;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.log4j.Logger;

import ubu.digit.util.ExternalProperties;

/**
 * Clase que genera el codigo html correspondiente a la página de
 * HistoricSist.html a partir de información en fichero externo al que se accede
 * por odbc.
 * <p>
 * Dependencias sobre recursos web ./css/ubuSisInf.css ./js/sorttable.js
 * <p>
 * Dependencia sobre los datos: Proyecto(Titulo, Descripcion, Tutor1, Tutor2,
 * Tutor3, Alumno1, Alumno2, Alumno3, CursoAsignacion) y
 * Alumno(Numero,ApellidosNombre,Dni,Repetidor,Asignado)
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 0.5
 */

public class DocCurrent extends DocSistInfHtml {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(DocCurrent.class);

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
     * URL de la página a seguir.
     */
    private static final String NAMEFICH_ACTUALES = DIROUT
            + "\\ActualesSist.html";

    /**
     * Cabecera de la página actual.
     */
    private static final String[] CURRENTHEADER = { "T&iacute;tulo",
            "Descripci&oacute;n", "Tutor/es", "Alumno/s", "CursoAsignacion" };

    /**
     * Submenús de la página.
     */
    private String[] titles = { "M&eacute;tricas",
            "Descripci&oacute;n de proyectos" };

    /**
     * Constructor vacío.
     */
    public DocCurrent() {

    }

    /**
     * Estrategia de generación del código html correspondiente a la página de
     * ActualesSist.html.
     * <p>
     * Genera el fichero ActualesSist.html a partir de los datos en un fichero
     * externo.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css, ./js/sorttable.js
     */
    @Override
    public void generate(int level) throws FileNotFoundException, SQLException {

        try {
            outHtml = new PrintStream(new FileOutputStream(NAMEFICH_ACTUALES),
                    true, CHARSET);
        } catch (UnsupportedEncodingException e) {
            LOGGER.error("CHARSET: " + CHARSET
                    + " no disponible en la máquina virtual", e);
        }

        outHtml.println("<!DOCTYPE html >");
        outHtml.println("<html lang=\"es\">");
        outHtml.println("\t<head>");
        createHeaderHtml("Sistemas Inform&aacute;ticos");
        outHtml.println("\t</head>");
        outHtml.println("\t<body>");
        outHtml.println("\t\t<div id='page-wrapper'>");
        outHtml.println("\t\t\t<div id='page'>");
        createMenuHtml(level);

        createCurrentStadistic(titles[0]);
        createCurrentTable(10, titles[1]);

        outHtml.println("\t\t\t\t</div>");
        outHtml.println("\t\t\t</div>");
        createFootHtml();
        createScript(WEB_JS_GOOGLEANALITICS_JS, "\t\t");
        outHtml.println("\t\t</div>");
        outHtml.println("\t</body>");
        outHtml.println("</html>");
        outHtml.close();
    }

    /**
     * Genera el código html correspondiente a la tabla estadística.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css
     * 
     * @param title
     *            Título de la tabla.
     * @throws SQLException
     */
    protected void createCurrentStadistic(String title) throws SQLException {
        outHtml.println("\t\t\t\t\t<section>");
        // Estadistica de Historico
        createSubTitleMenu(title);

        outHtml.println("\t\t\t\t\t\t<table>");
        String[] titulo = { "Informaci&oacute;n estad&iacute;stica", "" };
        this.createHeaderTable(titulo, "mdi-action-info", "small", null);
        outHtml.println("\t\t\t\t\t\t\t<tbody>");

        outHtml.println("\t\t\t\t\t\t\t\t<tr>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Proyectos: <br/>"
                + fachData.getTotalNumber("Titulo", "Proyecto") + " </td>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Proyectos sin asignar: <br/>"
                + fachData.getTotalFreeProject()
                + "<br/> Buscar la cadena 'Aalumnos sin asignar' en columna Alumnos.</td>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Alumnos: <br/>"
                + fachData.getTotalNumber("ApellidosNombre", "Alumno")
                + " </td>");
        String[] tutoresColumnNames = { "Tutor1", "Tutor2", "Tutor3" };
        outHtml.print("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Tutores Involucrados: <br/>"
                + fachData.getTotalNumber(tutoresColumnNames, "Proyecto")
                + " </td>");
        outHtml.println("\t\t\t\t\t\t\t\t</tr>");
        outHtml.println("\t\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t</table>");

        outHtml.println("\t\t\t\t\t</section>");

    }

    /**
     * Genera el código html correspondiente a una tabla con los proyectos del
     * curso actual.
     * 
     * @param nProyectPagina
     *            Número de filas visibles por página.
     * @param title
     *            Título de la tabla.
     * @throws SQLException
     */
    private void createCurrentTable(int nProyectPagina, String title)
            throws SQLException {
        outHtml.println("\t\t\t\t\t<section>");
        createSubTitleMenu(title);

        createPageIndex(nProyectPagina,
                fachData.getTotalNumber("Titulo", "Proyecto").intValue(), 'P');
        ResultSet result = fachData.getResultSet("Proyecto", "Titulo");
        outHtml.println(STR_WARN_TABLE_ORDENABLE);
        outHtml.println("\t\t\t\t\t\t<table class=\"sortable striped\">");
        this.createHeaderTable(CURRENTHEADER, "mdi-content-sort", "tiny", null);
        outHtml.println("\t\t\t\t\t\t<tbody>");

        int i = 0;
        while (result.next()) {

            outHtml.println("\t\t\t\t\t\t\t<tr id=\"P" + i
                    + "\"> <!-- Begin Proyecto-->");
            // Print Titulo Descripción
            outHtml.println("\t\t\t\t\t\t\t\t<th> "
                    + result.getString("Titulo") + "</th>");
            outHtml.println("\t\t\t\t\t\t\t\t<td> "
                    + result.getString("Descripcion") + "</td>");
            // Print Tutor
            outHtml.print("\t\t\t\t\t\t\t\t<td> " + result.getString("Tutor1"));
            String tutor2 = result.getString("Tutor2");
            if (tutor2 != null) {
                outHtml.print("<p></p>" + tutor2);
            }
            String tutor3 = result.getString("Tutor3");
            if (tutor3 != null) {
                outHtml.print("<p></p>" + tutor3);
            }
            outHtml.println(" </td>");

            // Print Alumnos
            String alumno1 = result.getString("Alumno1");
            if (alumno1 != null) {
                outHtml.print("\t\t\t\t\t\t\t\t<td> " + alumno1);
            }
            String alumno2 = result.getString("Alumno2");
            if (alumno2 != null) {
                outHtml.print("<p></p> " + alumno2);
            }
            String alumno3 = result.getString("Alumno3");
            if (alumno3 != null) {
                outHtml.print("<p></p> " + alumno3);
            }
            outHtml.println(" </td>");

            // Print Assignment date
            outHtml.println("\t\t\t\t\t\t\t\t<td> "
                    + result.getString("CursoAsignacion") + "</td>");
            outHtml.println("\t\t\t\t\t\t\t</tr><!-- End Proyecto-->");

            i++;
        }

        outHtml.println("\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t</table>");
        result.close();

        createPageIndex(nProyectPagina,
                fachData.getTotalNumber("Titulo", "Proyecto").intValue(), 'P');

        outHtml.println("\t\t\t\t\t</section>");

    }

    /**
     * Getter de los submenús que tiene la página.
     * 
     * @return Los submenús de la página.
     */
    public String[] getTitles() {
        return titles;
    }

    /**
     * Setter de los submenús que tiene la página.
     * 
     * @param titles
     *            Los títulos de los submenús a cambiar.
     */
    public void setTitles(String[] titles) {
        this.titles = titles;
    }
}
