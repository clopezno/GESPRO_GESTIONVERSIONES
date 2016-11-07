package ubu.digit.pesistence;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertThat;
import static org.powermock.api.mockito.PowerMockito.mockStatic;
import static org.powermock.api.mockito.PowerMockito.when;

import java.sql.SQLException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.JUnitCore;
import org.junit.runner.RunWith;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import ubu.digit.util.ExternalProperties;

/**
 * Conjunto de método que verifican la cobertura de la clase SistInfData.
 * 
 * @author Beatriz Zurera Martínez-Acitores
 *
 */
@RunWith(PowerMockRunner.class)
@PrepareForTest({ ExternalProperties.class, SistInfData.class })
public class SistInfDataTest {

    /**
     * Clase a testear.
     */
    SistInfData sistInfData;

    /**
     * URL del fichero donde se encuentra el fichero de configuración del test.
     */
    ExternalProperties test = ExternalProperties
            .getInstance("./../src/test/testConfig.properties");

    /**
     * Método que se ejecuta antes de cualquier test. Modifica el fichero de
     * configuración, por el propio del test.
     */
    @Before
    public void setUp() {
        mockStatic(ExternalProperties.class);

        when(ExternalProperties.getInstance("./../src/main/config.properties"))
                .thenReturn(test);

        sistInfData = SistInfData.getInstance();
    }

    /**
     * Test que comprueba que el método que obtiene la media de una lista de
     * números funciona correctamente.
     * <p>
     * En este caso, la columna "notas" es una lista de notas desde el 1 hasta
     * el 10 por lo que el resultado que esperamos es 5.5.
     * 
     * @throws Exception
     */
    @Test
    public void testAvg() throws Exception {
        Number esperado = sistInfData.getAvgColumn("Nota", "Prueba");
        assertThat(esperado, is((Number) 5.5F));
    }

    /**
     * Test que comprueba que el método que obtiene el valor máximo de un
     * listado funciona correctamente. En este caso, la columna "numero" tiene
     * como máximo un 9 y la columna "nota" tiene como máximo un 10.
     * 
     * @throws SQLException
     */
    @Test
    public void testMaxColumn() throws SQLException {

        String tableName = "Prueba";
        Number num = sistInfData.getMaxColumn("Numero", tableName);
        Number not = sistInfData.getMaxColumn("Nota", tableName);
        assertThat(num, is((Number) 9.0F));
        assertThat(not, is((Number) 10.0F));
        assertNotEquals(num, not);
    }

    /**
     * Test que comprueba que el método que obtiene el valor mínimo de un
     * listado funciona correctamente. En este caso, la columna "numero" tiene
     * como mínimo un 0 y la columna "nota" tiene como mínimo un 1.
     * 
     * @throws SQLException
     */
    @Test
    public void testMinColumn() throws SQLException {
        String tableName = "Prueba";
        Number num = sistInfData.getMinColumn("Numero", tableName);
        Number not = sistInfData.getMinColumn("Nota", tableName);
        assertThat(num, is((Number) 0.0F));
        assertThat(not, is((Number) 1.0F));
        assertNotEquals(num, not);
    }

    /**
     * Test que comprueba que el método que obtiene la desviación estándar de un
     * listado funciona correctamente. En este caso, la columna "numero" tiene
     * un listado de números de 0 a 9 y la columna "nota" un listado de 1 a 10,
     * por lo que en ambas esperamos la misma desviación.
     * 
     * @throws SQLException
     */
    @Test
    public void testStdvColumn() throws SQLException {
        String tableName = "Prueba";
        Number num = sistInfData.getStdvColumn("Numero", tableName);
        Number not = sistInfData.getStdvColumn("Nota", tableName);
        assertThat(num, is((Number) 3.0276503540974917));
        assertThat(not, is((Number) 3.0276503540974917));
        assertEquals(num, not);
    }

    /**
     * Este test comprueba que el método no nos devuelve conjunto vacíos de
     * datos.
     * 
     * @throws SQLException
     */
    @Test
    public void testResultSet() throws SQLException {
        assertThat(sistInfData.getResultSet("Prueba", "Numero"), notNullValue());

        assertThat(sistInfData.getResultSet("Prueba", "Nota",
                "Descripcion='hola'"), notNullValue());

        String[] metricValoreSelect = { "Numero", "Nota", "Descripcion" };
        assertThat(sistInfData.getResultSet("Prueba", "Numero", null,
                metricValoreSelect), notNullValue());
        assertThat(sistInfData.getResultSet("Prueba", "Numero",
                metricValoreSelect, null), notNullValue());
    }

    /**
     * Este test comprueba que el método devuelva correctamente el número de
     * filas según la ejecución SQL.
     * <p>
     * - En la primera pedimos que nos cuente el número de filas distintas donde
     * la nota sea un 5, que solo tenemos 1.
     * <p>
     * - En la segunda le pedimos que nos cuente el número de filas distintas de
     * la columna "nota" y "descripcion", por lo que esperamos 10 de la columna
     * "nota" + 2 de la columna "descripcion". Un total de 12.
     * <p>
     * - Y por último, pedimos que nos cuente una columna nula, que como no
     * existe pues nos devolverá 0. Y una columna que no existe, por lo que
     * lanzará una excepción SQL.
     * 
     * @throws SQLException
     */
    @Test(expected = SQLException.class)
    public void testTotalNumber() throws SQLException {

        Number obtenido = sistInfData.getTotalNumber("Nota", "Prueba",
                "Nota='5'");
        assertThat(obtenido, is((Number) 1.0F));

        String[] columnNames = { "Nota", "Descripcion" };
        Number obt = sistInfData.getTotalNumber(columnNames, "Prueba");
        assertThat(obt, is((Number) 12.0F));

        columnNames = null;
        obt = sistInfData.getTotalNumber(columnNames, "Prueba");
        assertThat(obt, is((Number) 0));

        String[] columnNam = { "Nada" };
        obt = sistInfData.getTotalNumber(columnNam, "Prueba");

    }

    @Test
    public void testQuartilColumn() throws SQLException {
        assertThat(sistInfData.getQuartilColumn("Nota", "Prueba", new Double(
                0.25)), notNullValue());
    }

    /**
     * En este test comprobamos que la obtención de la fecha máxima y la fecha
     * mínima funcione correctamente. La fecha mínima que esperamos es
     * 1/01/1649. Y la fecha máxima es 1/01/2015.
     * 
     * @throws SQLException
     */
    @Test
    public void testFechas() throws SQLException {
        Date esperado = sistInfData.getYear("Fecha", "Prueba", true);
        Calendar g = Calendar.getInstance();
        g.set(1649, Calendar.JANUARY, 1, 0, 0, 0);
        Date valor = new Date(g.getTimeInMillis());

        assertEqualDates(esperado, valor);

        esperado = sistInfData.getYear("Fecha", "Prueba", false);
        g.set(2015, Calendar.JANUARY, 1, 0, 0, 0);
        valor = new Date(g.getTimeInMillis());

        assertEqualDates(esperado, valor);
    }

    /**
     * Método que formatea las fechas y comprueba si son iguales.
     * 
     * @param expected
     *            Fecha esperada.
     * @param value
     *            Fecha obtenida.
     */
    private static void assertEqualDates(Date expected, Date value) {
        DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
        String strExpected = formatter.format(expected);
        String strValue = formatter.format(value);
        assertEquals(strExpected, strValue);
    }

    /**
     * Test que comprueba que salta la excepción SQLException al intentar
     * obtener datos de una tabla que no existe.
     * 
     * @throws SQLException
     */
    @Test(expected = SQLException.class)
    public void testSinTabla() throws SQLException {
        sistInfData.getAvgColumn("Nada", "Nada");
    }

    /**
     * Test que comprueba que salta la excepción SQLException al intentar
     * obtener datos de una tabla que está vacía.
     * 
     * @throws SQLException
     */
    @Test(expected = SQLException.class)
    public void testTablaVacia() throws SQLException {
        sistInfData.getAvgColumn("Nada", "Vacia");
    }

    /**
     * Método main.
     * 
     * @param args
     */
    public static void main(String[] args) {
        JUnitCore.main("ubu.digit.pesistence.SistInfDataTest");
    }
}
