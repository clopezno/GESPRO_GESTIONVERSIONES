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
 * Clase que genera el código html correspondiente a la página de index.html a
 * partir de información en fichero externo al que se accede por odbc.
 * <p>
 * Dependencias sobre recursos web: ./css/ubuSisInf.css
 * <p>
 * Dependencias sobre los datos: Tribunal(Cargo,NombreApellidos,Nick)
 * Norma(Descripcion) Calendario(Descripcion,Convocatoria,Fecha)
 * Documento(Descripcion,Url)
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 0.6
 */
public class DocIndex extends DocSistInfHtml {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(DocIndex.class);

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
    private static final String NAME_FICH_INDEX = DIROUT + "\\index.html";

    /**
     * Submenús de la página
     */
    private String[] titles = { "Tribunal", "Especificaciones de Entrega",
            "Fechas de Entrega", "Documentos" };

    /**
     * Constructor vacío.
     */
    public DocIndex() {

    }

    /**
     * Estrategia de generación del código html correspondiente a la página de
     * index.html. Genera el fichero index.html a partir de los datos en un
     * fichero externo.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css.
     */
    @Override
    public void generate(int level) throws FileNotFoundException, SQLException {
        try {
            outHtml = new PrintStream(new FileOutputStream(NAME_FICH_INDEX),
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

        int nTitulo = 0;
        for (String item : titles) {
            outHtml.println("\t\t\t\t\t<section>");
            this.createSubTitleMenu(item);

            switch (nTitulo) {
            case 0:
                createTribunal();
                break;
            case 1:
                createNormas();
                break;
            case 2:
                createCalendario();
                break;
            case 3:
                createDocumentos();
                break;
            default:
                break;
            }
            nTitulo++;
            outHtml.println("\t\t\t\t\t</section>");
        }

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
     * Estrategia de generación del codigo html correspondiente al subtitulo de
     * documentos de la página de index.html.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css.
     * 
     * @throws SQLException
     */
    private void createDocumentos() throws SQLException {
        ResultSet result = fachData.getResultSet("Documento", "Descripcion");

        outHtml.println("\t\t\t\t\t\t<ol class='ldoc'>");
        while (result.next()) {
            String descripcion = result.getString("Descripcion");
            String url = result.getString("Url");
            outHtml.println("\t\t\t\t\t\t\t<li><a href=\"" + url + "\"> "
                    + descripcion + "</a> </li>");
        }
        outHtml.println("\t\t\t\t\t\t</ol>");

        result.close();

    }

    /**
     * Estrategia de generación del codigo html correspondiente al subtitulo de
     * calendario de la página de index.html
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css.
     * 
     * @throws SQLException
     */
    private void createCalendario() throws SQLException {

        outHtml.println("\t\t\t\t\t\t<div class='calendar-container'>");

        String urlCalendario = "http://goo.gl/l4xy8Z";

        outHtml.println("\t\t\t\t\t\t\t<iframe src='" + urlCalendario
                + "'></iframe>");

        outHtml.println("\t\t\t\t\t\t</div>");

    }

    /**
     * Estrategia de generación del codigo html correspondiente al subtitulo de
     * Normas de la página de index.html
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css.
     * 
     * @throws SQLException
     */
    private void createNormas() throws SQLException {
        ResultSet result = fachData.getResultSet("Norma", "Descripcion");

        outHtml.println("\t\t\t\t\t\t<ol class='lnorm'>");
        while (result.next()) {
            String descripcion = result.getString("Descripcion");
            outHtml.println("\t\t\t\t\t\t\t<li>" + descripcion + "</li>");
        }
        outHtml.println("\t\t\t\t\t\t</ol>");

        result.close();
    }

    /**
     * Estrategia de generación del codigo html correspondiente al subtitulo de
     * Tribunal de la página de index.html
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css.
     * 
     * @throws SQLException
     */
    private void createTribunal() throws SQLException {

        outHtml.println("\t\t\t\t\t\t<table>");
        outHtml.println("\t\t\t\t\t\t\t<tr><td style='text-align:center' rowspan=\"6\"> <i class='large mdi-action-account-child'></i></td></tr>");

        ResultSet result = fachData.getResultSet("Tribunal", "NombreApellidos");

        while (result.next()) {
            String cargo = result.getString("Cargo");
            String nombre = result.getString("NombreApellidos");
            outHtml.println("\t\t\t\t\t\t\t<tr><td> " + cargo + ": " + nombre
                    + " </td></tr>");
        } // while

        result.close();
        outHtml.println("\t\t\t\t\t\t\t<tr><td colspan=\"2\">Programa en vigor a partir del Curso 2002-2003.</td>");
        outHtml.println("\t\t\t\t\t\t</tr></table>");

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