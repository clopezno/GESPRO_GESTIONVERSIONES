package ubu.digit.htmlgen;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;

import ubu.digit.util.ExternalProperties;

/**
 * Clase que genera el código html correspondiente a la página de
 * HistoricSist.html a partir de información en fichero externo al que se accede
 * por odbc.
 * <p>
 * Dependencias sobre recursos web: ./css/ubuSisInf.css ./js/sorttable.js
 * <p>
 * Dependencias sobtre los datos Historico(Titulo,Descripcion,Tutor1
 * ,Tutor2,Tutor3,Alumno1,Alumno2,Alumno3,FechaAsignacion
 * ,FechaPresentacion,Nota,TotalDias)
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 0.5
 * @version 2.0
 */
@SuppressWarnings({ "rawtypes", "unchecked" })
public class DocHistoric extends DocSistInfHtml {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(DocHistoric.class);

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
    protected static final String NAME_FICH_HISTORICO = DIROUT
            + "\\HistoricoSist.html";

    /**
     * Cabecera de la página actual.
     */
    protected static final String[] HISTORICOHEADER = { "T&iacute;tulo",
            "Tutor/es", "N# Alumno/s", "FechaAsignacion", "FechaPresentacion",
            "Nota" };

    /**
     * Submenús de la página.
     */
    private String[] titles = { "M&eacute;tricas",
            "Descripci&oacute;n de proyectos" };

    /**
     * Array borrador con los diferentes cursos.
     */
    private Map<Integer, List> cursosBorr = new HashMap<Integer, List>();

    /**
     * Array definitivo con los diferentes cursos que tienen proyectos de nueva
     * asignación.
     */
    private Map<Integer, List> cursosDefNuevos = new HashMap<Integer, List>();

    /**
     * Array definitivo con los diferentes cursos que tienen proyectos ya
     * asignados.
     */
    private Map<Integer, List> cursosDefViejos = new HashMap<Integer, List>();

    /**
     * Array con los cursos que tienen proyectos presentados.
     */
    private Map<Integer, List> cursosAgrupadosPresentacion = new HashMap<Integer, List>();

    /**
     * Estrategia de generación del codigo html correspondiente a la página de
     * HistoricSist.html.
     * <p>
     * Genera el fichero HistoricSist.html a partir de los datos en un fichero
     * externo.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css, ./js/sorttable.js
     * 
     */
    @Override
    public void generate(int level) throws FileNotFoundException, SQLException {

        try {
            outHtml = new PrintStream(
                    new FileOutputStream(NAME_FICH_HISTORICO), true, CHARSET);
        } catch (UnsupportedEncodingException e) {
            LOGGER.error("CHARSET: " + CHARSET
                    + " no disponible en la máquina virtual", e);
        }

        outHtml.println("<!DOCTYPE html >");
        outHtml.println("<html lang=\"es\">");
        outHtml.println("\t<head>");

        createHeaderHtml("Sistemas Inform&aacute;ticos");
        calcularProyectos();
        String funcion = "dibujar";
        createFunction(funcion);
        outHtml.println("\t</head>");
        outHtml.println("\t<body onload=\"" + funcion + "()\">");
        outHtml.println("\t\t<div id='page-wrapper'>");
        outHtml.println("\t\t\t<div id='page'>");
        createMenuHtml(level);

        createHistoricStadistic(titles[0]);
        createHistoricTable(10, titles[1]);

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
    private void createHistoricStadistic(String title) throws SQLException {
        outHtml.println("\t\t\t\t\t<section>");
        // Estadistica de Historico
        createSubTitleMenu(title);

        outHtml.println("\t\t\t\t\t\t<table>");
        String[] titulo = { "Informaci&oacute;n estad&iacute;stica", "", "", "" };
        this.createHeaderTable(titulo, "mdi-action-info", "small", null);
        outHtml.println("\t\t\t\t\t\t\t<tbody>");
        outHtml.println("\t\t\t\t\t\t\t\t<tr>");

        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Proyectos: "
                + numberFormat.format(fachData.getTotalNumber("Titulo",
                        "Historico")) + " </td>");

        String[] alumnosColumnNames = { "Alumno1", "Alumno2", "Alumno3" };
        Number totalAlumnos = fachData.getTotalNumber(alumnosColumnNames,
                "Historico");

        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Alumnos: "
                + numberFormat.format(totalAlumnos) + " </td>");

        outHtml.print("\t\t\t\t\t\t\t\t\t<td>Calificaci&oacute;n (media,min,max,stdv):<p></p> ("
                + numberFormat.format(fachData
                        .getAvgColumn("Nota", "Historico")));
        outHtml.print(", "
                + numberFormat.format(fachData
                        .getMinColumn("Nota", "Historico")));
        outHtml.print(", "
                + numberFormat.format(fachData
                        .getMaxColumn("Nota", "Historico")));
        outHtml.println(", "
                + numberFormat.format(fachData.getStdvColumn("Nota",
                        "Historico")) + ") </td>");

        outHtml.print("\t\t\t\t\t\t\t\t\t<td>Tiempo/d&iacute;as (media,min,max,stdv):<p></p> ("
                + numberFormat.format(fachData.getAvgColumn("TotalDias",
                        "Historico")));
        outHtml.print(", "
                + numberFormat.format(fachData.getMinColumn("TotalDias",
                        "Historico")));
        outHtml.print(", "
                + numberFormat.format(fachData.getMaxColumn("TotalDias",
                        "Historico")));
        outHtml.println(", "
                + numberFormat.format(fachData.getStdvColumn("TotalDias",
                        "Historico")) + ") </td>");

        outHtml.println("\t\t\t\t\t\t\t\t</tr>");

        createGlobalStadisticLine();
        outHtml.println("\t\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t</table>");
        outHtml.println("\t\t\t\t\t\t<p></p>");

        outHtml.println("\t\t\t\t\t</section>");

    }

    /**
     * Genera el código html correspondiente la fila de datos de la tabla
     * estadística.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css
     * 
     * @throws SQLException
     */
    private void createGlobalStadisticLine() throws SQLException {
        outHtml.println("\t\t\t\t\t\t\t\t<tr>");

        int keyMin = obtenerCurso(true).get(Calendar.YEAR);
        int keyMax = obtenerCurso(false).get(Calendar.YEAR);

        List<Number> nTotalProject = new ArrayList<Number>();
        List<Number> nTotalProjectPresented = new ArrayList<Number>();
        List<Number> nTotalAlumnos = new ArrayList<Number>();
        List<Number> nTotalTutores = new ArrayList<Number>();

        while (keyMin < keyMax) {
            nTotalProject.add(cursosDefNuevos.get(keyMin).size());
            nTotalAlumnos.add(calcularCountAlumnos().get(keyMin));
            nTotalTutores.add(calcularCountTutores().get(keyMin));
            nTotalProjectPresented.add(calcularProyectosPresentados().get(
                    keyMin));
            keyMin++;
        }

        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Proyectos Asignados por Curso:<br/> "
                + nTotalProject + " </td>");

        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Proyectos Presentados por Curso: <br/>"
                + nTotalProjectPresented + " </td>");

        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Alumnos Asignados por Curso: <br/>"
                + nTotalAlumnos + " </td>");

        outHtml.println("\t\t\t\t\t\t\t\t\t<td>N&uacute;mero Total de Tutores con nuevas asignaciones por Curso: <br/>"
                + nTotalTutores + " </td>");

        outHtml.println("\t\t\t\t\t\t\t\t</tr>");

        crearGraphicStadistic("grafica");
        crearGraphicStadistic("media");
    }

    /**
     * Genera el código correspondiente a la tabla de la pestaña de histórico.
     * 
     * @param id
     *            Identificador correspondiente a la gráfica.
     */
    private void crearGraphicStadistic(String id) {
        outHtml.println("\t\t\t\t\t\t\t\t<tr>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<td colspan='4' ><div  class='grafica' id=\""
                + id + "\" ></div></td>");
        outHtml.println("\t\t\t\t\t\t\t\t</tr>");
    }

    /**
     * Método que recoge los datos de la base de datos y los prepara para la
     * creación de la tabla de históricos.
     * 
     * @param nTotalProjectNuevos
     *            Proyectos de nueva asignación.
     * @param nTotalProjectViejos
     *            Proyectos ya asignados en cursos anteriores.
     * @param nTotalAlumnos
     *            Número total de alumnos.
     * @param nTotalTutores
     *            Número total de tutores.
     * @param cursos
     *            Listado con los cursos transcurridos desde el primer proyecto
     *            del histórico hasta el último.
     * @return Listado de todos los datos necesarios para la creación de la
     *         tabla.
     */
    private List<List> crearArrayGrafica(
            Map<Integer, Number> nTotalProjectNuevos,
            Map<Integer, Number> nTotalProjectViejos,
            Map<Integer, Number> nTotalAlumnos,
            Map<Integer, Number> nTotalTutores, List<Integer> cursos) {
        List<String> metricsName = new ArrayList<String>();
        metricsName.add("'Año'");
        metricsName.add("'Proyectos nuevos'");
        metricsName.add("'Proyectos ya asignados'");
        metricsName.add("'Alumnos Asignados'");
        metricsName.add("'Tutores Asignados'");

        List<List> data = new ArrayList<List>();
        data.add(metricsName);
        int keyMin = cursos.get(0);
        int keyMax = cursos.get(cursos.size() - 1);
        int index = 0;
        while (keyMin <= keyMax) {
            List<String> listData = new ArrayList<String>();
            int cur = cursos.get(index) - 1;
            listData.add('\'' + String.valueOf(cur) + '/'
                    + cursos.get(index).toString() + '\'');
            if (nTotalProjectNuevos.containsKey(keyMin)) {
                listData.add(nTotalProjectNuevos.get(keyMin).toString());
            }
            if (nTotalProjectViejos.containsKey(keyMin)) {
                listData.add(nTotalProjectViejos.get(keyMin).toString());
            }
            if (nTotalAlumnos.containsKey(keyMin)) {
                listData.add(nTotalAlumnos.get(keyMin).toString());
            }
            if (nTotalTutores.containsKey(keyMin)) {
                listData.add(nTotalTutores.get(keyMin).toString());
            }
            data.add(listData);
            keyMin++;
            index++;
        }
        return data;
    }

    /**
     * Método que recoge los datos de la base de datos y los prepara para la
     * creación de la tabla de históricos.
     * 
     * @param nMediaNotas
     *            Media de las notas de los proyectos.
     * @param nMediaMeses
     *            Media de los meses dedicados en los proyectos.
     * @param cursos
     *            Listado con los cursos transcurridos desde el primer proyecto
     *            del histórico hasta el último.
     * @return Listado de todos los datos necesarios para la creación de la
     *         tabla.
     */
    private List<List> crearArrayMedias(Map<Integer, Number> nMediaNotas,
            Map<Integer, Number> nMediaMeses, List<Integer> cursos) {
        List<String> medias = new ArrayList<String>(2);
        medias.add("'Año'");
        medias.add("'Media Aritmetica Notas'");
        medias.add("'Media Aritmetica Meses'");

        List<List> data = new ArrayList<List>();
        data.add(medias);

        int keyMin = cursos.get(0);
        int keyMax = cursos.get(cursos.size() - 1);
        int index = 0;

        while (keyMin <= keyMax) {
            List<String> listMedias = new ArrayList<String>();
            int cur = cursos.get(index) - 1;
            listMedias.add('\'' + String.valueOf(cur) + '/'
                    + cursos.get(index).toString() + '\'');
            if (nMediaNotas.containsKey(keyMin)) {
                listMedias.add(nMediaNotas.get(keyMin).toString());
            }
            if (nMediaMeses.containsKey(keyMin)) {
                listMedias.add(nMediaMeses.get(keyMin).toString());
            }
            data.add(listMedias);
            keyMin++;
            index++;
        }
        return data;
    }

    /**
     * Método que calcula la media aritmética del tiempo que llevó terminar el
     * proyecto.
     * 
     * @return Una tabla ordenada por cursos con cada media.
     * @throws SQLException
     */
    private Map<Integer, Number> calcularAvgDias() throws SQLException {
        int keyMin = obtenerCurso(true).get(Calendar.YEAR);
        int keyMax = obtenerCurso(false).get(Calendar.YEAR);
        Map<Integer, Number> nMediaFechas = new HashMap<Integer, Number>();
        while (keyMin < keyMax) {
            List current = new ArrayList();
            double media = 0;
            if (cursosDefNuevos.containsKey(keyMin)) {
                for (int index = 0; index < cursosDefNuevos.get(keyMin).size(); index++) {
                    current = (List) cursosDefNuevos.get(keyMin).get(index);
                    int dias = (int) current.get(2);
                    media += dias;
                }
            }
            media = media / cursosDefNuevos.get(keyMin).size();
            nMediaFechas.put(keyMin, media);
            keyMin++;
        }

        return nMediaFechas;
    }

    /**
     * Método que calcula la media aritmética de las notas
     * 
     * @return Una tabla ordenada por cursos con cada media.
     * @throws SQLException
     */
    private Map<Integer, Number> calcularAvgNotas() throws SQLException {
        int keyMin = obtenerCurso(true).get(Calendar.YEAR);
        int keyMax = obtenerCurso(false).get(Calendar.YEAR);
        Map<Integer, Number> nMediaNotas = new HashMap<Integer, Number>();
        while (keyMin < keyMax) {
            List current = new ArrayList();
            double media = 0;
            if (cursosDefNuevos.containsKey(keyMin)) {
                for (int index = 0; index < cursosDefNuevos.get(keyMin).size(); index++) {
                    current = (List) cursosDefNuevos.get(keyMin).get(index);
                    double dias = (double) current.get(3);
                    media += dias;
                }
            }
            media = media / cursosDefNuevos.get(keyMin).size();
            nMediaNotas.put(keyMin, media);
            keyMin++;
        }
        return nMediaNotas;
    }

    /**
     * Método que calcula el total de alumnos con proyectos asignados.
     * 
     * @return Una tabla ordenada por cursos con cada total de alumnos.
     * @throws SQLException
     */
    private Map<Integer, Number> calcularCountAlumnos() throws SQLException {
        int keyMin = obtenerCurso(true).get(Calendar.YEAR);
        int keyMax = obtenerCurso(false).get(Calendar.YEAR);
        Map<Integer, Number> nCountAlumnos = new HashMap<Integer, Number>();
        while (keyMin < keyMax) {
            List current = new ArrayList();
            int alumnos = 0;
            if (cursosDefNuevos.containsKey(keyMin)) {
                for (int index = 0; index < cursosDefNuevos.get(keyMin).size(); index++) {
                    current = (List) cursosDefNuevos.get(keyMin).get(index);
                    if (!"".equals(current.get(4)) && current.get(4) != null) {
                        alumnos++;
                    }
                    if (!"".equals(current.get(5)) && current.get(5) != null) {
                        alumnos++;
                    }
                    if (!"".equals(current.get(6)) && current.get(6) != null) {
                        alumnos++;
                    }
                }
            }
            nCountAlumnos.put(keyMin, alumnos);
            keyMin++;
        }
        return nCountAlumnos;
    }

    /**
     * Método que calcula el total de tutores con proyectos asignados.
     * 
     * @return Una tabla ordenada por cursos con cada total de tutores.
     * @throws SQLException
     */
    private Map<Integer, Number> calcularCountTutores() throws SQLException {
        int keyMin = obtenerCurso(true).get(Calendar.YEAR);
        int keyMax = obtenerCurso(false).get(Calendar.YEAR);
        Map<Integer, Number> nCountTutores = new HashMap<Integer, Number>();
        while (keyMin < keyMax) {
            List current = new ArrayList();
            int tutores = 0;
            if (cursosDefNuevos.containsKey(keyMin)) {
                for (int index = 0; index < cursosDefNuevos.get(keyMin).size(); index++) {
                    current = (List) cursosDefNuevos.get(keyMin).get(index);
                    if (!"".equals(current.get(7)) && current.get(7) != null) {
                        tutores++;
                    }
                    if (!"".equals(current.get(8)) && current.get(8) != null) {
                        tutores++;
                    }
                    if (!"".equals(current.get(9)) && current.get(9) != null) {
                        tutores++;
                    }
                }
            }
            nCountTutores.put(keyMin, tutores);
            keyMin++;
        }
        return nCountTutores;
    }

    /**
     * Método que ordena y obtiene los proyectos presentados según el curso.
     * 
     * @return Una tabla ordenada por cursos con los proyectos presentados.
     * @throws SQLException
     */
    private Map<Integer, Number> calcularProyectosPresentados()
            throws SQLException {
        int cursoMin = obtenerCurso(true).get(Calendar.YEAR);
        int cursoMax = obtenerCurso(false).get(Calendar.YEAR);
        Map<Integer, Number> hTotalProjectPresented = new HashMap<Integer, Number>();
        while (cursoMin < cursoMax) {
            List current = new ArrayList();
            Number presentados = 0;
            if (cursosAgrupadosPresentacion.containsKey(cursoMin)) {
                for (int index = 0; index < cursosAgrupadosPresentacion.get(
                        cursoMin).size(); index++) {
                    current = (List) cursosAgrupadosPresentacion.get(cursoMin)
                            .get(index);
                    if (current.get(1) != null && !"".equals(current.get(1))) {
                        presentados = presentados.intValue() + 1;
                    }
                }
            }
            hTotalProjectPresented.put(cursoMin, presentados);
            cursoMin++;
        }
        return hTotalProjectPresented;
    }

    /**
     * Método que recoge los datos para la creación de la tabla de históricos.
     * 
     * @return Listado de todos los datos necesarios para la creación de la
     *         tabla.
     * @throws SQLException
     */
    private List<List> createArrayStadisticLineGrafica() throws SQLException {

        Map<Integer, Number> nTotalProjectNuevos = new HashMap<Integer, Number>();
        Map<Integer, Number> nTotalProjectViejos = new HashMap<Integer, Number>();
        List<Integer> cursos = new ArrayList<Integer>();

        int cursoMin = obtenerCurso(true).get(Calendar.YEAR);
        int cursoMax = obtenerCurso(false).get(Calendar.YEAR);

        while (cursoMin < cursoMax) {
            cursos.add(cursoMin);
            int totalNuevos = 0;
            int totalViejos = 0;

            totalNuevos += cursosDefNuevos.get(cursoMin).size();
            if (cursosDefViejos.containsKey(cursoMin)) {
                totalViejos += cursosDefViejos.get(cursoMin).size();
            }
            nTotalProjectNuevos.put(cursoMin, totalNuevos);
            nTotalProjectViejos.put(cursoMin, totalViejos);
            cursoMin++;
        }

        Map<Integer, Number> nTotalAlumnos = calcularCountAlumnos();

        Map<Integer, Number> nTotalTutores = calcularCountTutores();

        return crearArrayGrafica(nTotalProjectNuevos, nTotalProjectViejos,
                nTotalAlumnos, nTotalTutores, cursos);
    }

    /**
     * Método que recoge los datos para la creación de la tabla de históricos de
     * medias.
     * 
     * @return Listado de todos los datos necesarios para la creación de la
     *         tabla.
     * @throws SQLException
     */
    private List<List> createArrayStadisticLineMedia() throws SQLException {

        List<Integer> cursos = new ArrayList<Integer>();
        int cursoMin = obtenerCurso(true).get(Calendar.YEAR);
        int cursoMax = obtenerCurso(false).get(Calendar.YEAR);

        while (cursoMin < cursoMax) {
            cursos.add(cursoMin);
            cursoMin++;
        }

        Map<Integer, Number> nMediaNotas = calcularAvgNotas();
        Map<Integer, Number> nMediaDias = calcularAvgDias();
        Map<Integer, Number> nMediaMeses = new HashMap<Integer, Number>();

        cursoMin = obtenerCurso(true).get(Calendar.YEAR);
        for (int index = cursoMin; index < cursoMax; index++) {
            Number n = nMediaDias.get(index);
            nMediaMeses.put(index, n.floatValue() / 31);
            cursoMin++;
        }
        return crearArrayMedias(nMediaNotas, nMediaMeses, cursos);
    }

    /**
     * Método que obtiene el curso mínimo o máximo según el booleano que se le
     * pase.
     * 
     * @param minimo
     *            booleano que nos dice si será mínimo o máximo.
     * @return la fecha con el curso mínimo o máximo.
     * @throws SQLException
     */
    private Calendar obtenerCurso(Boolean minimo) throws SQLException {

        if (minimo) {
            Calendar minFech = Calendar.getInstance();
            Long minMilis = fachData.getYear("FechaPresentacion", "Historico",
                    true).getTime();
            minFech.setTimeInMillis(minMilis);
            return minFech;
        } else if (!minimo) {
            Calendar maxFech = Calendar.getInstance();
            Long maxMilis = fachData.getYear("FechaPresentacion", "Historico",
                    false).getTime();
            maxFech.setTimeInMillis(maxMilis);
            return maxFech;
        }
        return null;
    }

    /**
     * Método que guarda todas fechas de asignación y presentación ordenadas por
     * curso.
     * 
     * @throws SQLException
     */
    private void calcularProyectos() throws SQLException {
        int curso = obtenerCurso(true).get(Calendar.YEAR);
        for (int index = curso; index < obtenerCurso(false).get(Calendar.YEAR) + 1; index++) {
            cursosBorr.put(index, fachData.getProjectsCurso("FechaAsignacion",
                    "FechaPresentacion", "TotalDias", "Nota", "Historico",
                    index));
        }
        prepararProyectos();
    }

    /**
     * Método que prepara los proyectos, es decir, coloca cada uno en su
     * respectivo curso. Teniendo en cuenta si los proyectos duran más de un
     * curso y si el proyecto se asignado antes de septiembre o después, ya que
     * corresponde a un curso más. La llave es la que define el curso, por
     * ejemplo si la llave es 2003 el curso es 2002-2003.
     * 
     * @throws SQLException
     */
    private void prepararProyectos() throws SQLException {
        int keyMin = obtenerCurso(true).get(Calendar.YEAR);
        int keyMax = obtenerCurso(false).get(Calendar.YEAR);
        while (keyMin < keyMax) {
            List current = new ArrayList();
            for (int index = 0; index < cursosBorr.get(keyMin).size(); index++) {
                current = (ArrayList) cursosBorr.get(keyMin).get(index);
                Calendar asig = Calendar.getInstance();
                asig.setTime((Date) current.get(0));
                Calendar sept = Calendar.getInstance();
                sept.set(keyMin,
                        Integer.parseInt(prop.getSetting("mesInicio")),
                        Integer.parseInt(prop.getSetting("diaInicio")));
                int dias = (int) current.get(2);
                int caso = dias / 360;

                // Comprobamos que la asignación fue realizada antes de la fecha
                // de inicio que hay en el fichero de configuración, ya que si
                // fue después tiene que ir en ese nuevo curso.
                if (asig.getTime().before(sept.getTime())) {
                    for (int i = 0; i <= caso; i++) {
                        construirProyectosDef(keyMin, i, current, true);
                    }
                } else {
                    // Esto es del nuevo curso porque fue asignado después de la
                    // fecha de inicio.
                    for (int i = 0; i <= caso; i++) {
                        construirProyectosDef(keyMin, i, current, false);
                    }
                }
                construirPresentados(current);
            }
            keyMin++;
        }
    }

    /**
     * Método auxiliar que construye el array para introducir los datos
     * correctamente en el mapa.
     * 
     * @param defin
     *            Proyecto actual.
     * @return Devuelve los proyectos en una estructura correcta.
     */
    private List<List> construirArray(List<List> defin) {
        List<List> aux = new ArrayList<List>();
        for (int index = 0; index < defin.size(); index++) {
            aux.add(defin.get(index));
        }
        return aux;

    }

    /**
     * Método auxiliar que añade los proyectos a su respectivo curso, teniendo
     * en cuenta la fecha de presentación de este.
     * 
     * @param current
     *            Proyecto actual.
     */

    private void construirPresentados(List current) {
        Calendar pres = Calendar.getInstance();
        pres.setTime((Date) current.get(1));

        Calendar sept = Calendar.getInstance();
        sept.set(pres.get(Calendar.YEAR), Calendar.OCTOBER, 1);
        if (pres.getTime().before(sept.getTime())) {
            if (cursosAgrupadosPresentacion
                    .containsKey(pres.get(Calendar.YEAR))) {
                List aux = construirArray(cursosAgrupadosPresentacion.get(pres
                        .get(Calendar.YEAR)));
                aux.add(current);
                cursosAgrupadosPresentacion.put(pres.get(Calendar.YEAR), aux);
            } else {
                List aux = new ArrayList();
                aux.add(current);
                cursosAgrupadosPresentacion.put(pres.get(Calendar.YEAR), aux);
            }
        }
    }

    /**
     * Método auxiliar que añade los proyectos a su respectivo curso, teniendo
     * en cuenta la fecha de asignación y presentación de este.
     * 
     * @param key
     *            Curso actual.
     * @param i
     *            Indice del array donde se encuentra el proyecto.
     * @param current
     *            Proyecto actual.
     * @param cursoActual
     *            True si el proyecto se corresponde con key, false si es de un
     *            curso más.
     */
    private void construirProyectosDef(int key, int i, List current,
            boolean cursoActual) {
        int antes = 0;
        if (!cursoActual) {
            antes = 1;
        }
        // Si es la segunda vez que pasa, es que el proyecto dura más de un
        // curso.
        if (i == 0) {
            if (cursosDefNuevos.containsKey(key + antes)) {
                List aux = construirArray(cursosDefNuevos.get(key + antes));
                aux.add(current);
                cursosDefNuevos.put(key + antes, aux);
            } else {
                List aux = new ArrayList();
                aux.add(current);
                cursosDefNuevos.put(key + antes, aux);
            }
        } else {
            if (cursosDefViejos.containsKey(key + i + antes)) {
                List aux = construirArray(cursosDefViejos.get(key + i + antes));
                aux.add(current);
                cursosDefViejos.put(key + i + antes, aux);
            } else {
                List aux = new ArrayList();
                aux.add(current);
                cursosDefViejos.put(key + i + antes, aux);
            }
        }
    }

    /**
     * Genera el código html correspondiente a una tabla con los proyectos
     * presentados en convocatorias pasadas.
     * 
     * @param nProyectPagina
     *            Número de filas visibles por página.
     * @param title
     *            Título de la tabla.
     * @throws ClassNotFoundException
     * @throws SQLException
     */
    private void createHistoricTable(int nProyectPagina, String title)
            throws SQLException {
        outHtml.println("\t\t\t\t\t<section>");
        createSubTitleMenu(title);

        createPageIndex(nProyectPagina,
                fachData.getTotalNumber("Titulo", "Historico").intValue(), 'P');

        ResultSet result = fachData.getResultSet("Historico", "Titulo");
        outHtml.println(STR_WARN_TABLE_ORDENABLE);
        outHtml.println("\t\t\t\t\t\t<table class=\"sortable striped\">");
        this.createHeaderTable(HISTORICOHEADER, "mdi-content-sort", "tiny",
                null);
        outHtml.println("\t\t\t\t\t\t\t<tbody>");

        int i = 0;
        while (result.next()) {
            // impar

            outHtml.println("\t\t\t\t\t\t\t\t<tr id=\"P" + i
                    + "\"> <!-- Begin Proyecto-->");
            // Print Titulo
            outHtml.println("\t\t\t\t\t\t\t\t\t<th> "
                    + result.getString("Titulo") + "</th>");
            // Print Tutor
            outHtml.print("\t\t\t\t\t\t\t\t\t<td> "
                    + result.getString("Tutor1"));
            String tutor2 = result.getString("Tutor2");
            if (tutor2 != null && !"".equals(tutor2)) {
                outHtml.print("<p></p>" + tutor2);
            }
            String tutor3 = result.getString("Tutor3");
            if (tutor3 != null && !"".equals(tutor3)) {
                outHtml.print("<p></p>" + tutor3);
            }
            outHtml.println(" </td>");
            // Print numero de alumnos
            int numAlu = 1;

            String alumno = result.getString("Alumno2");
            if (alumno != null && !"".equals(alumno)) {
                numAlu++;
            }
            alumno = result.getString("Alumno3");
            if (alumno != null && !"".equals(alumno)) {
                numAlu++;
            }
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> " + numAlu + " </td>");
            // Print Assignment date
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> "
                    + result.getString("FechaAsignacion") + "</td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> "
                    + result.getString("FechaPresentacion") + "</td>");
            // Print qualification
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> "
                    + result.getString("Nota").replaceAll(",", ".") + "</td>");
            outHtml.println("\t\t\t\t\t\t\t\t</tr><!-- End Proyecto-->");

            i++;
        }
        outHtml.println("\t\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t</table>");
        result.close();
        createPageIndex(nProyectPagina,
                fachData.getTotalNumber("Titulo", "Historico").intValue(), 'P');

        outHtml.println("\t\t\t\t\t</section>");
    }

    /**
     * Genera el código html correspondiente al script de carga del gráfico de
     * históricos.
     * 
     * @param datosGraf
     *            Datos a cargar en la gráfica.
     * @param id
     *            id de la gráfica.
     * @param titulo
     *            Título de la gráfica.
     */
    private void createScriptGraph(List<List> datosGraf, String id,
            String titulo) {
        outHtml.println("\t\t\t google.setOnLoadCallback(drawChart("
                + datosGraf + ", \"" + id + "\", \"" + titulo + "\"));");
    }

    /**
     * Genera la función de carga de las gráficas en el script del head.
     * 
     * @param funcion
     *            Nombre de la función del script.
     * @throws SQLException
     */
    private void createFunction(String funcion) throws SQLException {
        outHtml.println("\t\t<script type='text/javascript'>");
        outHtml.println("\t\t\tfunction " + funcion + "(){");
        createScriptGraph(createArrayStadisticLineGrafica(), "grafica",
                "Metricas agrupadas por curso");
        createScriptGraph(createArrayStadisticLineMedia(), "media",
                "Medias agrupadas por curso");
        outHtml.println("\t\t\t}");
        outHtml.println("\t\t</script> ");
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
