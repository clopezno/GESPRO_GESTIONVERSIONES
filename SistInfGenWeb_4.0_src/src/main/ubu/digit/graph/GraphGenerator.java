package ubu.digit.graph;

import java.awt.Color;
import java.awt.Font;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Vector;

import org.apache.log4j.Logger;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.DatasetRenderingOrder;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYBoxAndWhiskerRenderer;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.statistics.BoxAndWhiskerItem;
import org.jfree.data.statistics.DefaultBoxAndWhiskerXYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

import ubu.digit.util.ExternalProperties;

/**
 * Clase encargada de generar gráficos estadísticos.
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 0.5
 * @version 2.0
 */

public class GraphGenerator {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(GraphGenerator.class);

    /**
     * URL donde encontramos el fichero con las propiedades del proyecto.
     */
    private static ExternalProperties prop = ExternalProperties
            .getInstance("./../src/main/config.properties");

    /**
     * Constructor.
     */
    public GraphGenerator() {
        super();
    }

    /**
     * Método que crea el gráfico de los intervalos de las métricas de producto.
     * 
     * @param title
     *            Título del gráfico.
     * @param xLabel
     *            Rótulo del título del eje de las x's.
     * @param yLabel
     *            Rótulo del título del eje de las y's.
     * @param etiquetas
     *            Etiquetas que aparecen en el gráfico.
     * @param valores
     *            Valores que aparecen el gráfico.
     */
    public void generateGraphicBoxPlot(String title, String descripcion,
            String xLabel, String yLabel, Vector<String> etiquetas,
            Vector<Vector<Double>> valores) {

        DefaultBoxAndWhiskerXYDataset dataset = this
                .createBoxPlotDataset(valores);

        JFreeChart chart = ChartFactory.createBoxAndWhiskerChart(title, xLabel,
                yLabel, dataset, false);

        chart.setTitle(new TextTitle(title + "_" + descripcion, new Font(
                "Verdana", Font.PLAIN, 9)));

        XYPlot plot = (XYPlot) chart.getPlot();

        plot.setOrientation(PlotOrientation.HORIZONTAL);
        XYBoxAndWhiskerRenderer renderer = (XYBoxAndWhiskerRenderer) plot
                .getRenderer();
        renderer.getBaseItemLabelsVisible();
        renderer.setFillBox(true);
        renderer.setBoxWidth(20);
        renderer.setBoxPaint(Color.LIGHT_GRAY);

        // Create a simple XY chart
        XYSeries series = new XYSeries("XYGraph");
        for (int i = 0; i < etiquetas.size(); ++i) {
            series.add((i) * 10, dataset.getMeanValue(0, i));
        }
        // Add the series to your data set
        XYSeriesCollection dataset2 = new XYSeriesCollection();
        dataset2.addSeries(series);

        plot.setDataset(1, dataset2);
        final XYLineAndShapeRenderer renderer2 = new XYLineAndShapeRenderer();
        renderer2.setSeriesPaint(0, Color.blue);
        plot.setRenderer(1, renderer2);
        plot.setDatasetRenderingOrder(DatasetRenderingOrder.FORWARD);

        plot.getDomainAxis().setVisible(false);
        plot.getRangeAxis().setRange(
                plot.getRangeAxis().getRange().getLowerBound() - 1,
                plot.getRangeAxis().getRange().getUpperBound() + 1);

        try {
            ChartUtilities.saveChartAsPNG(new File(prop.getSetting("dirOut")
                    + "\\images\\metrics\\" + title + ".png"), chart, 250, 60);
        } catch (IOException e) {
            LOGGER.error("Error al crear el gráfico", e);
        }
    }

    /**
     * Crea el conjunto de datos (dataset) con los que se obtendrá el gráfico de
     * caja y bigotes.
     *
     * @param valores
     *            Colección de colecciones de datos de series
     * @return Conjunto de valores (dataset) para generar el gráfico
     * @see org.jfree.data.statistics.DefaultBoxAndWhiskerXYDataset
     * @see org.jfree.data.statistics.BoxAndWhiskerItem
     */
    protected DefaultBoxAndWhiskerXYDataset createBoxPlotDataset(
            Vector<Vector<Double>> valores) {

        DefaultBoxAndWhiskerXYDataset dataSetMetric = new DefaultBoxAndWhiskerXYDataset(
                "");

        for (int abc = 0; abc < valores.size(); ++abc) {

            List<Double> lista = new ArrayList<Double>();
            int k;
            double aux;
            int entero;
            double suma = 0;
            double media, mediana, primerCuartil, tercerCuartil;

            lista.addAll(valores.elementAt(abc));

            // ***************** Ordenar lista ********************
            for (int i = 0; i < lista.size(); i++) {
                k = i;
                for (int j = i + 1; j < lista.size(); j++) {
                    if (lista.get(j) < lista.get(k)) {
                        k = j;
                    }
                }
                aux = lista.get(k);
                lista.set(k, lista.get(i));
                lista.set(i, aux);
            }

            for (int i = 0; i < lista.size(); i++) {
                suma = suma + lista.get(i);
            }
            media = suma / lista.size();

            if (lista.size() % 2 != 0) {
                mediana = lista.get(lista.size() / 2);
            } else {
                mediana = (lista.get(lista.size() / 2) + lista.get((lista
                        .size() / 2) - 1)) / 2;
            }

            entero = Math.round((lista.size() * 25) / 100);
            primerCuartil = lista.get(entero);

            entero = Math.round((lista.size() * 75) / 100);
            tercerCuartil = lista.get(entero);

            BoxAndWhiskerItem item = new BoxAndWhiskerItem(
                    // media
                    media,
                    // mediana
                    mediana,
                    // primer cuartil
                    primerCuartil,
                    // tercer cuartil
                    tercerCuartil,
                    // Primer cuartil - 1,5 * RIC y primer cuartil - 3 * RIC
                    primerCuartil - (1.5) * (tercerCuartil - primerCuartil),
                    // Tercer cuartil + 1,5 * RIC y tercer cuartil + 3 * RIC
                    tercerCuartil + (1.5) * (tercerCuartil - primerCuartil),
                    -10000, 10000, lista);

            dataSetMetric.add(new Date(abc * 10), item);
        }
        return dataSetMetric;
    }
}
