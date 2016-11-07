package ubu.digit.htmlgen;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;

import org.apache.log4j.Logger;

import ubu.digit.graph.GraphGenerator;
import ubu.digit.util.ExternalProperties;
import ubu.digit.util.ThresHold;

/**
 * Clase que genera el código html correspondiente a la página de
 * MetricSist.html a partir de información en fichero externo al que se accede
 * por odbc, necesita las siguientes datos: DescripcionExperimento(Descripcion)
 * MetricaDescripcion(Id,Tipo,MinValor,MaxValor,Visible)
 * MetricaValores(M0,M1,...) donde M0 y M1 se debe corresponder con las filas
 * del atributo Id .
 * <p>
 * Dependencias sobre recursos web: ./web/css/ubuSisInf.css
 * ./web/js/tip_followscroll.js, ./web/js/wz_tooltip.js
 * ./web/js/tip_centerwindow.js./web/js/googleanalitics.js ./web/js/sorttable.js
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 0.5
 * @version 2.0
 */
public class DocMetric extends DocSistInfHtml {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(DocMetric.class);

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
    protected static final String NAME_FICH_METRIC = DIROUT
            + "\\MetricSist.html";

    /**
     * Conjunto de valores visibles
     */
    protected String[] metricValoreSelect;

    /**
     * Cabecera de la tabla de cobertura de proyectos
     */
    protected String[] metricValoreHeader;

    /**
     * Tool Tip de la cabecera de la tabla de cobertura de proyectos
     */
    protected String[] metricValoresOHeaderToolTip;

    /**
     * Almacena todos los intervalos relativos de la Ubu. Contiene tantos
     * elementos como métricas visibles. Si la métrica es de tipo cadena se crea
     * un intervalo con inicialización especial.
     */
    private ThresHold[] thresHoldUBUQ1Q3;

    /**
     * Almacena todos los intervalos aconsejados por la herramienta de medida.
     * Contiene tantos elementos como métricas visibles. Si la métrica es de
     * tipo cadena se crea un intervalo con inicialización especial.
     */
    private ThresHold[] thresHoldTool;

    /**
     * Almacena todas las medias aritméticas de los valores de las métricass de
     * la Ubu. Contiene tantos elementos como métricas visibles. Si la métrica
     * es de tipo cadena se crea un valor centinela.
     */
    private Number[] avgsUBU;

    /**
     * Almacena todas las medianas de los valores de las métricas de la Ubu.
     * Contiene tantos elementos como métricas visibles. Si la métrica es de
     * tipo cadena se crea un valor centinela.
     */
    private Number[] medsUBU;

    /**
     * Cabecera de la tabla de cobertura globales de proyectos
     */
    protected static final String[] METRICDESCRIPCIONHEADER = { "DESCRIPCION",
            "Min", "Max", "Min_b", "Q1_b", "Avg_b", "Q2_b", "Q3_b", "Max_b",
            "BOXPLOT_UBU" };

    /**
     * ToolTip de la cabecera de la tabla de cobertura globales de proyectos
     */
    protected static final String[] METRICDESCRIPCIONTOOLTIP = {
            "Nombre Completo de la M&eacute;trica.",
            "M&iacute;nimo valor recomendado por la herramienta de medida. Es un campo opcional.",
            "M&aacute;ximo valor recomendado por la herramienta de medida. Es un campo opcional.",
            "M&iacute;nimo valor en proyectos de la asignatura de Sistemas Inform&aacute;ticos de 5º II de la UBU.",
            "Valor del 25% de la muestra en proyectos de la asignatura de Sistemas Inform&aacute;ticos de 5º II de la UBU.",
            "Valor de la media aritm&eacute;tica en proyectos de la asignatura de Sistemas Inform&aacute;ticos de 5º II de la UBU.",
            "Valor de la mediana de la muestra en proyectos de la asignatura de Sistemas Inform&aacute;ticos de 5º II de la UBU.",
            "Valor del 75% de la muestra en proyectos de la asignatura de Sistemas Inform&aacute;ticos de 5º de la UBU.",
            "M&aacute;ximo valor en proyectos de la asignatura de Sistemas Inform&aacute;ticos de 5º II de la UBU.",
            "Gr&aacute;fico resumen con los datos estad&iacute;sticos e la asignatura de Sistemas Inform&aacute;ticos de 5º de la UBU." };

    /**
     * Submenús de la página.
     */
    private String[] titles = { "Descripci&oacute;n del experimento",
            "Intervalos de M&eacute;tricas de Producto",
            "Coberturas Globales de M&eacute;tricas", "Coberturas de Proyectos" };

    /**
     * Inicializa dinamicamente las cabeceras y tooltip de las tablas a partir
     * de las métricas que tiene el atributo visible=true en la tabla
     * MetricaDescripcion. Se inicializan los atributos necesarios que serán
     * utilizados en la consultas posteriores. Permite definir diferentes
     * experimentos combiando unicamente los datos.
     * 
     * @throws SQLException
     *             si se no se puede tener acceso al sistema de almacenamiento.
     */
    public DocMetric() throws SQLException {
        super();
        createMetricValoresHeader();
        thresHoldUBUQ1Q3 = new ThresHold[metricValoreSelect.length];
        thresHoldTool = new ThresHold[metricValoreSelect.length];
        avgsUBU = new Number[metricValoreSelect.length];
        medsUBU = new Number[metricValoreSelect.length];

    }

    /**
     * Inicializa dinamicamente las cabeceras y tooltip de las tablas a partir
     * de las métricas que tiene el atributo visible=true en la tabla
     * MetricaDescripcion. Se inicializan los atributos necesarios que serán
     * utilizados en la consultas posteriores.
     * 
     * @throws SQLException
     *             si se no se puede tener acceso al sistema de almacenamiento.
     */
    private void createMetricValoresHeader() throws SQLException {
        Number nMetrics = fachData.getTotalNumber("Id", "MetricaDescripcion",
                "Visible='true'");

        metricValoreHeader = new String[nMetrics.intValue() + 1];
        metricValoresOHeaderToolTip = new String[nMetrics.intValue() + 1];
        metricValoreSelect = new String[nMetrics.intValue()];

        metricValoreHeader[0] = " ";
        metricValoresOHeaderToolTip[0] = " M0 + M1";

        ResultSet result = fachData.getResultSet("MetricaDescripcion", "Id",
                "Visible='true'");
        int indexHeader = 1, indexSelect = 0;
        while (result.next()) {
            String description = result.getString("Descripcion");
            String id = result.getString("Id");
            metricValoreSelect[indexSelect] = id;
            indexSelect++;
            if ((!"M0".equals(id)) && (!"M1".equals(id))) {
                metricValoreHeader[indexHeader] = id;
                metricValoresOHeaderToolTip[indexHeader] = description;
                indexHeader++;
            }
        }
        result.close();
        metricValoreHeader[indexHeader] = "Cobertura UBU";
        metricValoresOHeaderToolTip[indexHeader++] = "Cobertura  Ubu";

        metricValoreHeader[indexHeader] = "Cobertura  Tool";
        metricValoresOHeaderToolTip[indexHeader] = "Cobertura  Tool";
    }

    /**
     * Estrategia de generación del codigo html correspondiente a la página de
     * MetricSist.html. Genera el fichero MetricSist.html a partir de los datos
     * en un fichero externo.
     * <p>
     * Dependencias sobre ./css/ubuSisInf.css, ./js/sorttable.js
     * 
     */
    @Override
    public void generate(int level) throws FileNotFoundException, SQLException {

        try {
            outHtml = new PrintStream(new FileOutputStream(NAME_FICH_METRIC),
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
        outHtml.println("\t\t<script  src='./js/wz_tooltip.js'  type='text/javascript'></script>");
        outHtml.println("\t\t<div id='page-wrapper'>");
        outHtml.println("\t\t\t<div id='page'>");
        createMenuHtml(level);

        createExperimentDescription(titles[0]);
        createMetricDescriptionStadistic(titles[1]);
        createMetricCover(titles[2]);
        createMetricCoverProject(titles[3]);

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
     * Estrategia de generación del codigo html correspondiente a la descripción
     * del experimento.
     * <p>
     * Dependencias sobre la tabla: DescripcionExperimento(Descripcion)
     * 
     * @throws SQLException
     */
    private void createExperimentDescription(String title) throws SQLException {

        Number nFiles = fachData.getTotalNumber("Descripcion",
                "DescripcionExperimento");
        outHtml.println("\t\t\t\t\t<section>");
        createSubTitleMenu(title);

        outHtml.println("\t\t\t\t\t\t<table>");
        outHtml.println("\t\t\t\t\t\t\t<tr><td rowspan=\""
                + (nFiles.intValue() + 1)
                + "\"> <img src='./images/ico_experimento.jpg' alt='experimento'/> </td></tr>");

        ResultSet result = fachData.getResultSet("DescripcionExperimento",
                "Descripcion");

        while (result.next()) {
            String descripcion = result.getString("Descripcion");

            outHtml.println("\t\t\t\t\t\t\t<tr><td> " + descripcion
                    + " </td></tr>");
        }

        result.close();

        outHtml.println("\t\t\t\t\t\t</table>");
        outHtml.println("\t\t\t\t\t\t<div>");
        createScript(DIROUT + "\\html\\videotutorialsourcemonitor.html",
                "\t\t\t\t\t\t\t");

        createScript(DIROUT + "\\html\\videotutorialcodeeval.html",
                "\t\t\t\t\t\t\t");
        outHtml.println("\t\t\t\t\t\t</div>");

        outHtml.println("\t\t\t\t\t</section>");
    }

    /**
     * Genera el codigo html correspondiente a una tabla con los intervalos de
     * métricas globales y su comparativa con valores estadísticos de los datos
     * de la UBU. Inicializa los intervalos relativos de la UBU.
     * <p>
     * Dependencias sobre las tablas.
     * MetricaDescripcion(Id,Tipo,MinValor,MaxValor,Visible)
     * MetricaValores(M0,M1,...) donde M0 y M1 se debe corresponder con las
     * filas del atributo Id .
     * 
     * @param title
     *            título del sub Apartado
     * @throws SQLException
     */
    private void createMetricDescriptionStadistic(String title)
            throws SQLException {
        // Descripción de metricas

        ResultSet result = fachData.getResultSet("MetricaDescripcion", "ID",
                metricValoreSelect, null);
        outHtml.println("\t\t\t\t\t<section>");
        createSubTitleMenu(title);

        createDescriptionStadistic("Comparaci&oacute;n de los intervalos proporcionado por las herramientas respecto a los valores de los proyectos de 5º de Ingenier&iacute;a Inform&aacute;tica");

        createPageIndex(10, metricValoreSelect.length, 'P');

        outHtml.println("\t\t\t\t\t\t<table>");

        this.createHeaderTable(METRICDESCRIPCIONHEADER, "mdi-action-info",
                "small", METRICDESCRIPCIONTOOLTIP);
        outHtml.println("\t\t\t\t\t\t\t<tbody>");

        int i = 0;
        while (result.next()) {

            outHtml.println("\t\t\t\t\t\t\t\t<tr id=\'P" + i + "'>");

            String id = result.getString("Id");
            String descripcion = result.getString("Descripcion");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td>" + descripcion + "</td>");

            String strMinValor = result.getString("MinValor").replaceAll(",",
                    ".");
            String strMaxValor = result.getString("MaxValor").replaceAll(",",
                    ".");

            createAndPrintTDThresholdTool(i, strMaxValor, strMinValor);

            String tipoId = result.getString("Tipo");
            createAndPrintTDMinQ1MedAvgQ3MaxThresholdUbu(i, id, descripcion,
                    strMaxValor, strMinValor, tipoId);

            outHtml.println("\t\t\t\t\t\t\t\t</tr>");
            i++;

        }
        result.close();

        outHtml.println("\t\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t</table>");

        createPageIndex(10, metricValoreSelect.length, 'P');

        outHtml.println("\t\t\t\t\t</section>");
    }

    /**
     * Genera el código html de celdas <td>con los valores estadisticos
     * maximo,minimo, media aritmética, mediana, q1,q3 comparandolos con los
     * intervalos recomendados por las herramientas a través de códigos de
     * colores. Crea un gráfico boxplot. Se valida que el tipo de la descripción
     * de la métrica sea numérico y que exista intervalo recomendado para la
     * métrica.
     * 
     * @param i
     *            número de métrica tratada. Necesario para actualizar las
     *            colecciones de datos estadísticos de la UBU.
     * @param id
     *            identificador de la métrica.
     * @param descripcion
     *            descripción de la métrica.
     * @param strMaxValor
     *            máximo valor recomendado.
     * @param strMinValor
     *            mínimo valor recomendado.
     * @param tipoId
     *            tipo de la métrica tratada.
     * @throws SQLException
     * @throws NumberFormatException
     */
    private void createAndPrintTDMinQ1MedAvgQ3MaxThresholdUbu(int i, String id,
            String descripcion, String strMaxValor, String strMinValor,
            String tipoId) throws SQLException {
        if ("number".equals(tipoId)) {
            Number maxUbu = fachData.getMaxColumn(id, "MetricaValores");
            Number minUbu = fachData.getMinColumn(id, "MetricaValores");
            Number avgUbu = fachData.getAvgColumn(id, "MetricaValores");
            Number q1Ubu = fachData.getQuartilColumn(id, "MetricaValores",
                    new Double(0.25));
            Number medUbu = fachData.getQuartilColumn(id, "MetricaValores",
                    new Double(0.5));
            Number q3Ubu = fachData.getQuartilColumn(id, "MetricaValores",
                    new Double(0.75));

            if (q1Ubu.doubleValue() > q3Ubu.doubleValue()) {
                thresHoldUBUQ1Q3[i] = new ThresHold(q1Ubu, q3Ubu);
            } else {
                thresHoldUBUQ1Q3[i] = new ThresHold(q3Ubu, q1Ubu);
            }

            avgsUBU[i] = avgUbu;
            medsUBU[i] = medUbu;

            if (strMaxValor != null && strMinValor != null
                    && !"".equals(strMinValor) && !"".equals(strMaxValor)) {
                Double maxValor = new Double(strMaxValor);
                Double minValor = new Double(strMinValor);

                createHtmlTableTDColor(minUbu, maxValor, minValor);

                createHtmlTableTDColor(q1Ubu, maxValor, minValor);
                createHtmlTableTDColor(avgUbu, maxValor, minValor,
                        "ico_bolaazul.png");
                createHtmlTableTDColor(medUbu, maxValor, minValor,
                        "ico_barra.png");
                createHtmlTableTDColor(q3Ubu, maxValor, minValor);
                createHtmlTableTDColor(maxUbu, maxValor, minValor);

            } else {

                outHtml.println("\t\t\t\t\t\t\t\t\t<td>"
                        + numberFormat.format(minUbu) + "</td>");

                outHtml.println("\t\t\t\t\t\t\t\t\t<td>"
                        + numberFormat.format(q1Ubu) + "</td>");
                outHtml.println("\t\t\t\t\t\t\t\t\t<td><img src='./images/ico_bolaazul.png' alt=' ' />"
                        + numberFormat.format(avgUbu) + "</td>");
                outHtml.println("\t\t\t\t\t\t\t\t\t<td><img src='./images/ico_barra.png' alt=' ' />"
                        + numberFormat.format(medUbu) + "</td>");
                outHtml.println("\t\t\t\t\t\t\t\t\t<td>"
                        + numberFormat.format(q3Ubu) + "</td>");
                outHtml.println("\t\t\t\t\t\t\t\t\t<td>"
                        + numberFormat.format(maxUbu) + "</td>");
            }

            createHtmlTableTdBoxPlot(id, descripcion);

        } else {
            thresHoldUBUQ1Q3[i] = new ThresHold();
            avgsUBU[i] = -50000;
            medsUBU[i] = -50000;
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
        }
    }

    /**
     * Genera el código html de celdas <td>con los valores recomendados por la
     * herramienta, pasados como parámetros. Se actualizan los datos de la
     * colección de intervalos de las métricas en el caso que los valores sean
     * distintos de nulo.
     *
     * @param i
     *            número de métrica tratada. Necesario para actualizar las
     *            colecciones de intervalos aconsejados.
     * @param strMaxValor
     *            valor máximo del intervalo.
     * @param strMinValor
     *            valor mínimo del intervalo.
     * @throws NumberFormatException
     */
    private void createAndPrintTDThresholdTool(int i, String strMaxValor,
            String strMinValor) {
        if (strMaxValor != null && strMinValor != null
                && !"".equals(strMinValor) && !"".equals(strMaxValor)) {
            outHtml.println("\t\t\t\t\t\t\t\t\t<td>"
                    + numberFormat.format(new Double(strMinValor)) + "</td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td>"
                    + numberFormat.format(new Double(strMaxValor)) + "</td>");
            thresHoldTool[i] = new ThresHold(new Double(strMaxValor),
                    new Double(strMinValor));
        } else {
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
            outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
            thresHoldTool[i] = new ThresHold();
        }
    }

    /**
     * Genera el codigo html correspondiente al sub_apartado cobertura globales
     * de métricas. Se genera una tabla con los indicadores gráficos de
     * cobertura. Las coleciones de intervalos, de medias aritméticas y medianas
     * deben estar inicializadas y deben contener el mismo número de valores.
     * 
     * @param title
     *            título del subapartado
     * @throws SQLException
     */
    private void createMetricCover(String title) {
        outHtml.println("\t\t\t\t\t<section>");
        createSubTitleMenu(title);

        int nTotalMetrics = 0;
        int nCorrectMetricsQ1Q3 = 0;
        int nCorrectMetricsMed = 0;
        int nCorrectMetricsAvg = 0;
        int index = 0;

        for (index = 0; index < thresHoldTool.length; index++) {
            if (thresHoldTool[index].isInit()) {
                nTotalMetrics++;
                if (thresHoldTool[index].isInThreshold(thresHoldUBUQ1Q3[index])) {
                    nCorrectMetricsQ1Q3++;
                }
                if (thresHoldTool[index].isInThreshold(avgsUBU[index])) {
                    nCorrectMetricsAvg++;
                }
                if (thresHoldTool[index].isInThreshold(medsUBU[index])) {
                    nCorrectMetricsMed++;
                }
            }
        }

        outHtml.println("\t\t\t\t\t\t<ol class='lnorm'>");
        outHtml.println("\t\t\t\t\t\t\t<li> Porcentajes de Cobertura de las metricas con intervalos recomendados respecto a las m&eacute;tricas "
                + "de los proyectos de la asignatura de 5º de Ingenier&iacute;a Inform&aacute;tica de la Universidad de Burgos.</li>");
        outHtml.println("\t\t\t\t\t\t</ol>");

        outHtml.println("\t\t\t\t\t\t<table>");
        outHtml.println("\t\t\t\t\t\t\t<thead>");
        outHtml.println("\t\t\t\t\t\t\t\t<tr>");
        outHtml.println("\t\t\t\t\t\t\t\t<th> Porcentaje de Cobertura respecto Q1Q3</th>");
        outHtml.println("\t\t\t\t\t\t\t\t<th> Porcentaje de Cobertura respecto Avg</th> ");
        outHtml.println("\t\t\t\t\t\t\t\t<th> Porcentaje de Cobertura respecto Med</th>");
        outHtml.println("\t\t\t\t\t\t\t\t</tr>");
        outHtml.println("\t\t\t\t\t\t\t</thead>");

        outHtml.println("\t\t\t\t\t\t\t<tbody>");
        outHtml.println("\t\t\t\t\t\t\t\t<tr>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<td>");
        createCoverMetricTable(new Double(nCorrectMetricsQ1Q3), new Double(
                nTotalMetrics));
        outHtml.println("\t\t\t\t\t\t\t\t\t</td>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<td>");
        createCoverMetricTable(new Double(nCorrectMetricsAvg), new Double(
                nTotalMetrics));
        outHtml.println("\t\t\t\t\t\t\t\t\t</td>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<td>");
        createCoverMetricTable(new Double(nCorrectMetricsMed), new Double(
                nTotalMetrics));
        outHtml.println("\t\t\t\t\t\t\t\t\t</td>");
        outHtml.println("\t\t\t\t\t\t\t\t</tr>");
        outHtml.println("\t\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t</table>");

        outHtml.println("\t\t\t\t\t</section>");

    }

    /**
     * Genera el codigo html correspondiente a una tabla con los valores de las
     * métricas de los proyectos y su comparativa con los intervalos
     * recomendables por la herramienta y por los relativos con la
     * oreganización.
     * <p>
     * Dependencias sobre las tablas. MetricaValores(M0,M1,...) donde M0 y M1 se
     * debe corresponder con las filas del atributo Id .
     * 
     * @param title
     *            título del sub Apartado
     * @throws SQLException
     */
    private void createMetricCoverProject(String title) throws SQLException {
        // Descripción de metricas

        ResultSet result = fachData.getResultSet("MetricaValores", "M0", null,
                metricValoreSelect);
        outHtml.println("\t\t\t\t\t<section>");
        createSubTitleMenu(title);

        createDescriptionStadistic("Valores de las metricas de los proyectos de 5º de Ingenier&iacute;a Inform&aacute;tica comparados con los intervalos recomendados ");
        int nProject = fachData.getTotalNumber("M0", "MetricaValores")
                .intValue();
        createPageIndex(10, nProject, 'S');
        outHtml.println(STR_WARN_TABLE_ORDENABLE);
        outHtml.println("\t\t\t\t\t\t<table class=\"sortable\">");

        this.createHeaderTable(metricValoreHeader, "mdi-action-info", "small",
                metricValoresOHeaderToolTip);
        outHtml.println("\t\t\t\t\t\t\t<tbody>");

        int nRec = 0;
        while (result.next()) {
            outHtml.println("\t\t\t\t\t\t\t\t<tr id=\'S" + nRec + "'>");
            int nField = 0;

            int nCorrectMetricQ1Q2 = 0;
            int nTotalMetricQ1Q2 = 0;

            int nCorrectMetricTool = 0;
            int nTotalMetricTool = 0;

            String nameProject = result.getString(metricValoreSelect[0]);
            String languageProject = result.getString(metricValoreSelect[1]);

            outHtml.println("\t\t\t\t\t\t\t\t\t<td onmouseover=\"Tip('"
                    + nameProject + "')\" onmouseout=\"UnTip()\"> "
                    + "<img src='./images/ico_" + languageProject
                    + ".gif' alt='" + languageProject + "'/> </td>");
            for (nField = 2; nField < metricValoreSelect.length; nField++) {
                String data = result.getString(metricValoreSelect[nField])
                        .replaceAll(",", ".");
                if (data != null && !"".equals(data)) {

                    if (thresHoldTool[nField].isInit()) {

                        Number dataValor = new Double(data);
                        createHtmlTableTDColor(dataValor, thresHoldTool[nField]
                                .getMax().doubleValue(), thresHoldTool[nField]
                                .getMin().doubleValue());
                        if (thresHoldTool[nField].isInThreshold(dataValor)) {
                            nCorrectMetricTool++;
                        }
                        nTotalMetricTool++;
                    } else {
                        outHtml.println("\t\t\t\t\t\t\t\t\t<td>" + data
                                + "</td>");
                    }

                    if (thresHoldUBUQ1Q3[nField].isInit()) {

                        Number dataValor = new Double(data);
                        if (thresHoldUBUQ1Q3[nField].isInThreshold(dataValor)) {
                            nCorrectMetricQ1Q2++;
                        }
                        nTotalMetricQ1Q2++;
                    }

                } else {
                    outHtml.println("\t\t\t\t\t\t\t\t\t<td> - </td>");
                }

            }

            outHtml.println("\t\t\t\t\t\t\t\t\t<td>");
            this.createCoverMetricTable(new Double(nCorrectMetricQ1Q2),
                    new Double(nTotalMetricQ1Q2));
            outHtml.println("\t\t\t\t\t\t\t\t\t</td>");

            outHtml.println("\t\t\t\t\t\t\t\t\t<td>");
            this.createCoverMetricTable(new Double(nCorrectMetricTool),
                    new Double(nTotalMetricTool));
            outHtml.println("\t\t\t\t\t\t\t\t\t</td>");

            outHtml.println("\t\t\t\t\t\t\t\t</tr>");
            nRec++;

        }
        result.close();

        outHtml.println("\t\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t</table>");

        createPageIndex(10, nProject, 'S');

        outHtml.println("\t\t\t\t\t</section>");
    }

    /**
     * Genera una lista informativa html no numerada con una descripción
     * indicando la leyenda de los colores utilizados.
     * 
     * @param description
     *            descripción de los valores representados.
     */
    private void createDescriptionStadistic(String description) {
        outHtml.println("\t\t\t\t\t\t<ol class='lnorm'>");
        outHtml.println("\t\t\t\t\t\t\t<li> " + description + " </li>");
        outHtml.println("\t\t\t\t\t\t</ol>");
        outHtml.println("\t\t\t\t\t\t<p class=\"green\"> VERDE: Si el valor esta dentro del intervalo. </p>");
        outHtml.println("\t\t\t\t\t\t<p class=\"red\"> ROJO: Si el valor  no esta dentro del intervalo.</p>");
        outHtml.println("\t\t\t\t\t\t<p> NEGRO: Si no existe intervalo recomendado.</p>");
    }

    /**
     * Genera un celda de una tabla html con una imagen cuyo nombre se
     * corresponde con la concatenación de los datos pasados como parametros. La
     * imagen se genera dinámicamente a partir de la consulta de los datos de la
     * tabla MetricaValores
     * 
     * @param id
     *            identificacion de la métrica
     * @param descripcion
     *            descripción
     * @throws SQLException
     */
    private void createHtmlTableTdBoxPlot(String id, String descripcion)
            throws SQLException {
        Vector<String> metricsIdNumeric = new Vector<String>(20);
        Vector<Vector<Double>> valoresMetrics = new Vector<Vector<Double>>(20);
        Vector<Double> valoresMetric = new Vector<Double>(100);
        metricsIdNumeric.add(id);
        ResultSet result2 = fachData.getResultSet("MetricaValores", id);
        while (result2.next()) {
            Double value = result2.getDouble(id);
            valoresMetric.add(value);

        }
        result2.close();
        valoresMetrics.add(valoresMetric);
        GraphGenerator graph = new GraphGenerator();
        graph.generateGraphicBoxPlot(id, descripcion, "", "", metricsIdNumeric,
                valoresMetrics);
        outHtml.println("\t\t\t\t\t\t\t\t\t<td><img src='./images/metrics/"
                + id + ".png' alt='boxplot'/></td>");
    }

    /**
     * Genera un celda de una tabla html cuyo contenido estará en verde si el
     * valor esta dentro del intervalo y rojo en caso contrario.
     * 
     * @param data
     *            valor a escribir.
     * @param maxValor
     *            máximo valor del intervalo.
     * @param minValor
     *            mínimo valor del interval.
     */
    private void createHtmlTableTDColor(Number data, Double maxValor,
            Double minValor) {
        ThresHold thres = new ThresHold(maxValor, minValor);
        if (data.doubleValue() > maxValor || data.doubleValue() < minValor) {
            outHtml.println("\t\t\t\t\t\t\t\t\t<td class='red' onmouseover=\"Tip('"
                    + thres
                    + "')\" onmouseout=\"UnTip()\">"
                    + numberFormat.format(data.doubleValue()) + "</td>");
        } else {
            outHtml.println("\t\t\t\t\t\t\t\t\t<td class='green'  onmouseover=\"Tip('"
                    + thres
                    + "')\" onmouseout=\"UnTip()\">"
                    + numberFormat.format(data.doubleValue()) + "</td>");
        }

    }

    /**
     * Genera un celda de una tabla html cuyo contenido estará en verde si el
     * valor esta dentro del intervalo y rojo en caso contrario. El contenido de
     * la celda esta compuesto por un dato y un string con una imagen.
     * 
     * @param data
     *            valor a escribir.
     * @param maxValor
     *            máximo valor del intervalo.
     * @param minValor
     *            mínimo valor del interval.
     * @param img
     *            url de la imagen a añadir
     */
    private void createHtmlTableTDColor(Number data, Double maxValor,
            Double minValor, String img) {
        ThresHold thres = new ThresHold(maxValor, minValor);
        if (data.doubleValue() > maxValor || data.doubleValue() < minValor) {
            outHtml.println("\t\t\t\t\t\t\t\t\t<td class='red' onmouseover=\"Tip('"
                    + thres
                    + "')\" onmouseout=\"UnTip()\"> <img src='./images/"
                    + img
                    + "' alt=' ' />"
                    + numberFormat.format(data.doubleValue())
                    + "</td>");
        } else {
            outHtml.println("\t\t\t\t\t\t\t\t\t<td class='green' onmouseover=\"Tip('"
                    + thres
                    + "')\" onmouseout=\"UnTip()\"> <img src='./images/"
                    + img
                    + "' alt=' ' />"
                    + numberFormat.format(data.doubleValue())
                    + "</td>");
        }
    }

    /**
     * Genera una tabla html que representa el indicador gráfico de cobertura.
     * 
     * @param nCorrectData
     *            número de datos correctos.
     * @param nTotalData
     *            número de datos totales.
     */
    private void createCoverMetricTable(Double nCorrectData, Double nTotalData) {

        outHtml.println("\t\t\t\t\t\t\t\t<table>");
        outHtml.println("\t\t\t\t\t\t\t\t\t<tbody>");
        outHtml.println("\t\t\t\t\t\t\t\t\t\t<tr>");

        outHtml.println("\t\t\t\t\t\t\t\t\t\t\t<td class=\"percentgraph\">");
        outHtml.println("\t\t\t\t\t\t\t\t\t\t\t\t<div class=\"progress\">");
        outHtml.println("\t\t\t\t\t\t\t\t\t\t\t\t\t<div class=\"determinate\" style=\"width:"
                + numberFormat.format(nCorrectData / nTotalData * 100).replace(
                        ',', '.') + "%;\"></div>");
        outHtml.println("\t\t\t\t\t\t\t\t\t\t\t\t</div>");
        outHtml.println("\t\t\t\t\t\t\t\t\t\t\t</td>");
        outHtml.println("\t\t\t\t\t\t\t\t\t\t\t<td>"
                + numberFormat.format(nCorrectData) + "/"
                + numberFormat.format(nTotalData) + "</td>");
        outHtml.println("\t\t\t\t\t\t\t\t\t\t</tr>");
        outHtml.println("\t\t\t\t\t\t\t\t\t</tbody>");
        outHtml.println("\t\t\t\t\t\t\t\t</table>");
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
