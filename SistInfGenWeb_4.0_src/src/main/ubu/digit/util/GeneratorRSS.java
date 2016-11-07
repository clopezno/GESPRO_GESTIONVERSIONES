package ubu.digit.util;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.util.Date;

/**
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 *
 */
public class GeneratorRSS {

    /**
     * Variable que tiene la ISO que tiene la página web.
     */
    protected static final String CHARSET = "UTF-8";

    /**
     * Archivo de salida.
     */
    private PrintStream outRss;

    /**
     * Constructor de la clase.
     * 
     * @param path
     *            Ruta donde se encontrará el archivo.
     * @param charset
     *            ISO que tendrá el archivo.
     * @throws UnsupportedEncodingException
     * @throws FileNotFoundException
     */
    public GeneratorRSS(String path, String charset)
            throws UnsupportedEncodingException, FileNotFoundException {
        outRss = new PrintStream(new FileOutputStream(path), true, charset);
    }

    /**
     * Generador del canal.
     */
    public void generateFootRSSChannel() {
        outRss.println("<channel>");
    }

    /**
     * Características del canal.
     */
    public void generateChannelProperties() {
        String tab = "\t";
        Date date = new Date(System.currentTimeMillis());

        outRss.println("<?xml version=\"1.0\" encoding=\"" + CHARSET + "\" ?>");
        outRss.println("<rss version=\"2.0\">");
        outRss.println("<channel>");
        outRss.println(tab + "<title>Sistemas Informáticos</title>");
        outRss.println(tab
                + "<link>http://pisuerga.inf.ubu.es/lsi/Asignaturas/SI/</link>");
        outRss.println(tab
                + "<description>Información de la Asignatura de Sistemas Informáticos de 5º de Ingeniería Informática</description>");
        outRss.println(tab + "<language>es</language>");
        outRss.println(tab + "<image>");
        outRss.println(tab + "\t<title>LSI</title>");
        outRss.println(tab
                + "\t<url>http://pisuerga.inf.ubu.es/lsi/Asignaturas/SI/images/logoLSI.gif</url>");
        outRss.println(tab
                + "\t<link>http://pisuerga.inf.ubu.es/lsi/Asignaturas/SI/</link>");
        outRss.println(tab + "\t<width>26</width>");
        outRss.println(tab + "\t<height>23</height>");
        outRss.println(tab
                + "\t<description>Area de Lenguajes y Sistemas Informáticos</description>");
        outRss.println(tab + "</image>");
        outRss.println(tab + "<pubDate>Thu Feb 19 19:17:41 CET 2009</pubDate>");
        outRss.println(tab + "<lastBuildDate>" + date.toString()
                + "</lastBuildDate>");
    }

    /**
     * Generador del ítem.
     * 
     * @param tab
     *            Tabulador.
     * @param title
     *            Título del ítem.
     * @param link
     *            URL del ítem.
     * @param description
     *            Descripción del ítem que hemos añadido.
     */
    public void generateItem(String tab, String title, String link,
            String description) {

        outRss.println(tab + "<item>");
        outRss.println(tab + "\t<title>" + title + "</title>");
        outRss.println(tab + "\t<link>" + link + "</link>");
        outRss.println(tab + "\t<description>" + description + "</description>");
        outRss.println(tab + "</item>");
    }

    /**
     * Main de la clase.
     * 
     * @param args
     * @throws UnsupportedEncodingException
     * @throws FileNotFoundException
     */
    public static void main(String[] args) throws UnsupportedEncodingException,
            FileNotFoundException {

        GeneratorRSS g = new GeneratorRSS(".\\ejemplo.rss", "UTF-8");
        g.generateFootRSSChannel();

    }

}
