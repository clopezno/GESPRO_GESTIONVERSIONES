package ubu.digit.pesistence;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;

import ubu.digit.util.ExternalProperties;

/**
 * Fachada Singleton de acceso a datos a través de un recurso
 * jdbc:relique:csv:dir (directorio donde se encuentra). Se proporciona una hoja
 * de datos con la definición de la estructura para probar sus funciones.
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 0.5
 */
public class SistInfData {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(SistInfData.class);

    /**
     * Conexión que se produce entre la base de datos y la aplicación.
     */
    private Connection connection;

    /**
     * Instancia con los datos.
     */
    private static SistInfData instance;

    /**
     * Recurso a través se produce el acceso.
     */
    private static final String URL = "jdbc:relique:csv:";

    /**
     * URL donde encontramos el fichero con las propiedades del proyecto.
     */
    private static ExternalProperties prop = ExternalProperties
            .getInstance("./../src/main/config.properties");

    /**
     * Directorio donde se encuentra los datos de entrada, es decir, los
     * ficheros que contienen los datos que vamos a consultar.
     */
    private static final String DIRCSV = prop.getSetting("dataIn");

    /**
     * Constructor vacío.
     */
    private SistInfData() {
        super();
        this.connection = this.getConection(URL);
    }

    /**
     * Método singleton para obtener la instancia de la clase fachada.
     */
    public static SistInfData getInstance() {
        if (instance == null) {
            instance = new SistInfData();
        }
        return instance;
    }

    /**
     * Inicializa la conexión odbc al almacen de datos.
     * 
     * @param url
     *            cadena de conexión jdbc.csv.
     */
    private Connection getConection(String url) {
        Connection con = null;
        try {
            Class.forName("org.relique.jdbc.csv.CsvDriver");

            con = DriverManager.getConnection(url + DIRCSV);

        } catch (ClassNotFoundException e) {
            LOGGER.error(e);
        } catch (SQLException e) {
            LOGGER.error(e);
        }
        return con;
    }

    /**
     * Ejecuta una sentencia SQL sumando todos los datos Float contenidos en la
     * primera columna.
     * 
     * @param SQL
     *            sentencia sql a ejecutar
     * @return suma todas la filas de la primera columna
     */
    private Number getResultSetNumber(String sql) {
        Number number = 0;
        boolean hasResults;

        try {
            Statement statement = connection.createStatement();
            hasResults = statement.execute(sql);

            if (hasResults) {
                ResultSet result = statement.getResultSet();

                if (result != null) {
                    result.next();
                    number = result.getFloat(1);
                }
                result.close();
            }
        } catch (SQLException e) {
            LOGGER.error(e);
        }
        return number;
    }

    /**
     * Ejecuta una sentencia SQL obteniendo la media aritmética de la columna de
     * la tabla ambas pasadas como parámetro.
     * 
     * @param columnName
     *            nombre de la columna
     * @param tableName
     *            nombre de la tabla de datos
     * @return media aritmética
     * @throws SQLException
     */
    public Number getAvgColumn(String columnName, String tableName)
            throws SQLException {

        List<Float> media = obtenerDatos(columnName, tableName);
        Float resultadoMedia = new Float(0);

        for (Float numero : media) {
            resultadoMedia += numero;
        }

        return resultadoMedia / media.size();
    }

    /**
     * Ejecuta una sentencia SQL obteniendo el valor máximo de la columna de una
     * tabla, ambas pasadas como parámetro.
     * 
     * @param columnName
     *            nombre de la columna
     * @param tableName
     *            nombre de la tabla de datos
     * @return valor máximo de la columna
     * @throws SQLException
     */
    public Number getMaxColumn(String columnName, String tableName)
            throws SQLException {

        return Collections.max(obtenerDatos(columnName, tableName));
    }

    /**
     * Ejecuta una sentencia SQL obteniendo el valor mínimo de la columna de una
     * tabla, ambas pasadas como parámetro.
     * 
     * @param columnName
     *            nombre de la columna
     * @param tableName
     *            nombre de la tabla de datos
     * @return valor mínimo de la columna
     * @throws SQLException
     */
    public Number getMinColumn(String columnName, String tableName)
            throws SQLException {

        return Collections.min(obtenerDatos(columnName, tableName));
    }

    /**
     * Ejecuta una sentencia SQL obteniendo la desviación estandart de la
     * columna de una tabla, ambas pasadas como parámetro.
     * 
     * @param columnName
     *            nombre de la columna
     * @param tableName
     *            nombre de la tabla de datos
     * @return desviación estandar
     * @throws SQLException
     */
    public Number getStdvColumn(String columnName, String tableName)
            throws SQLException {

        return calculateStdev(obtenerDatos(columnName, tableName));
    }

    /**
     * Obtiene los datos de una columna determinada de una tabla determinada.
     * 
     * @param columnName
     *            nombre de la columna
     * @param tableName
     *            nombre de la tabla de datos
     * @return Listado con los datos de dicha columna.
     */
    private List<Float> obtenerDatos(String columnName, String tableName)
            throws SQLException {
        Statement statement = connection.createStatement();
        String sql = "Select " + columnName + " from " + tableName + ";";
        ResultSet result = statement.executeQuery(sql);

        // Capturamos los metadatos de la tabla
        ResultSetMetaData rmeta = result.getMetaData();
        int numColumns = rmeta.getColumnCount();
        List<Float> media = new ArrayList<Float>();
        // Recorremos las filas del cursor
        while (result.next()) {
            for (int i = 1; i <= numColumns; ++i) {
                media.add(result.getFloat(i));
            }
        } // while
        result.close();
        return media;
    }

    /**
     * Calcula la desviación standard.
     * 
     * @param list
     *            Listado de los números de los que calcular la desviación.
     * @return Desviación standard.
     */
    private Double calculateStdev(List<Float> list) {
        double sum = 0;

        // Taking the average to numbers
        for (int i = 0; i < list.size(); i++) {
            sum = sum + list.get(i);
        }

        double mean = sum / list.size();

        double[] deviations = new double[list.size()];

        // Taking the deviation of mean from each numbers
        for (int i = 0; i < deviations.length; i++) {
            deviations[i] = list.get(i) - mean;
        }

        double[] squares = new double[list.size()];

        // getting the squares of deviations
        for (int i = 0; i < squares.length; i++) {
            squares[i] = deviations[i] * deviations[i];
        }

        sum = 0;

        // adding all the squares
        for (int i = 0; i < squares.length; i++) {
            sum = sum + squares[i];
        }

        // dividing the numbers by one less than total numbers
        double result = sum / (list.size() - 1);

        // Taking square root of result gives the
        // standard deviation
        return Math.sqrt(result);
    }

    /**
     * Ejecuta una sentencia SQL obteniendo la mediana de la columna de una
     * tabla, ambas pasadas como parámetro.
     * 
     * @param columnName
     *            nombre de la columna
     * @param tableName
     *            nombre de la tabla de datos
     * @return mediana
     * @throws SQLException
     * @throws SQLException
     */
    public Number getQuartilColumn(String columnName, String tableName,
            double percent) throws SQLException {

        Number nTotalValue = getTotalNumber(columnName, tableName);

        String sql = "Select " + columnName + " from " + tableName + " where "
                + columnName + "!= ''" + " order by " + columnName;

        List<Double> listValues = getListNumber(columnName, sql);

        int indexMedian = new Double(nTotalValue.intValue() * percent)
                .intValue();

        return listValues.get(indexMedian);
    }

    /**
     * @param columnName
     *            Nombre de la columna.
     * @param SQL
     *            Sentencia a ejecutar.
     * @return listado con los números.
     * @throws SQLException
     */
    private List<Double> getListNumber(String columnName, String sql)
            throws SQLException {
        List<Double> listValues = new ArrayList<Double>(100);

        Statement statement = connection.createStatement();
        Boolean hasResults = statement.execute(sql);

        if (hasResults) {
            ResultSet result = statement.getResultSet();

            while (result.next()) {
                listValues.add(result.getDouble(columnName));
            }
            result.close();
        }
        return listValues;
    }

    /**
     * Ejecuta una sentencia SQL obteniendo el número total de filas diferentes,
     * distintas de null y cumplen la claúsula where de la columna de una tabla.
     * 
     * @param columnName
     *            nombre de la columna.
     * @param tableName
     *            nombre de la tabla de datos.
     * @return número total de filas distintas
     * @throws SQLException
     */
    public Number getTotalNumber(String columnName, String tableName)
            throws SQLException {

        String sql = "Select distinct count(" + columnName + ")" + "from "
                + tableName + " where " + columnName + " != '';";

        return getResultSetNumber(sql);
    }

    /**
     * Ejecuta una sentencia SQL obteniendo el número total de filas diferentes,
     * distintas de null y que cumplan el filtro de la columna de una tabla.
     * 
     * @param columnName
     *            nombre de la columna
     * @param tableName
     *            nombre de la tabla de datos
     * @param whereCondition
     *            filtro con la condición
     * @return número total de filas distintas
     * @throws SQLException
     */
    public Number getTotalNumber(String columnName, String tableName,
            String whereCondition) throws SQLException {

        String sql = "Select distinct count(" + columnName + ")" + " from "
                + tableName + " where " + columnName + " != '' AND "
                + whereCondition + " ;";

        return getResultSetNumber(sql);
    }

    /**
     * Ejecuta una sentencia SQL obteniendo el número total de filas diferentes
     * y distintas de null de las columnas de una tabla pasadas como parámetro.
     * 
     * @param columnsName
     *            nombre de las columnas
     * @param tableName
     *            nombre de la tabla de datos
     * @return número total de filas distintas
     * @throws SQLException
     */
    public Number getTotalNumber(String[] columnsName, String tableName)
            throws SQLException {
        String sql = null;
        Set<String> noDups = new HashSet<String>();
        if (columnsName != null) {

            for (int i = 0; i < columnsName.length; i++) {
                sql = "Select " + columnsName[i] + " from " + tableName
                        + " where " + columnsName[i] + " != '';";
                Statement statement = connection.createStatement();
                ResultSet results = statement.executeQuery(sql);

                ResultSetMetaData rmeta = results.getMetaData();
                int numColumns = rmeta.getColumnCount();
                // Recorremos las filas del cursor
                while (results.next()) {
                    for (int j = 1; j <= numColumns; ++j) {
                        noDups.add(results.getString(j));
                    }
                } // while
            }

            return (float) noDups.size();
        } else {
            return 0;
        }
    }

    /**
     * Ejecuta una sentencia SQL obteniendo el número total de proyectos sin
     * asignar. Se busca una cadena que contenga la subcadena "Aal".
     * 
     * @return número total de proyectos sin asignar
     * @throws SQLException
     */
    public Number getTotalFreeProject() throws SQLException {
        String sql = "Select count(*) " + "from Proyecto "
                + " where Alumno1 like '%Aal%'";

        return getResultSetNumber(sql);
    }

    /**
     * Ejecuta una sentencia SQL obteniendo un conjunto de filas distintas de
     * nulo de una columna de una tabla, ambas pasadas como parámetros.
     * 
     * @param columnName
     *            nombre de la columna a discriminar el contador.
     * @param tableName
     *            nombre de la tabla de datos.
     * @return conjunto de filas distintas de null.
     * @throws SQLException
     */
    public ResultSet getResultSet(String tableName, String columnName)
            throws SQLException {
        Statement statement = connection.createStatement();
        String sql = "Select * " + " from " + tableName + " where "
                + columnName + " != '';";

        return statement.executeQuery(sql);
    }

    /**
     * Ejecuta una sentencia SQL obteniendo un conjunto de filas distintas de
     * nulo y cumplen la condición pasada como parámetro.
     * 
     * @param columnName
     *            nombre de la columna a discriminar con nulos.
     * @param tableName
     *            nombre de la tabla de datos.
     * @param whereCondition
     *            condición de la claúsula where.
     * @return conjunto de filas distintas de null y condición de la claúsula
     *         where.
     * @throws SQLException
     */
    public ResultSet getResultSet(String tableName, String columnName,
            String whereCondition) throws SQLException {
        Statement statement = connection.createStatement();
        String sql = "Select * " + " from " + tableName + " WHERE "
                + whereCondition + ";";
        statement.execute(sql);
        return statement.getResultSet();
    }

    /**
     * Ejecuta una sentencia SQL obteniendo un conjunto de filas distintas de
     * nulo y que contienen las cadenas pasadas como filtros de una columna de
     * una tabla, ambas pasadas como parámetro.
     * 
     * @param tableName
     *            nombre de la tabla de datos.
     * @param columnName
     *            nombre de la columna a discriminar el contador.
     * @param filters
     *            valores de las columnas que continen las cadenas filters.
     * @param columnsName
     *            nombres de las columnas a seleccionar
     * @return conjunto de filas distintas de null.
     * @throws SQLException
     */
    public ResultSet getResultSet(String tableName, String columnName,
            String[] filters, String[] columnsName) throws SQLException {
        Statement statement = connection.createStatement();
        String sql;
        if (columnsName == null) {
            sql = "Select * ";
        } else {
            sql = "Select ";
            int index = 0;
            for (String selectedColumn : columnsName) {
                if (index == 0) {
                    sql += " " + selectedColumn;
                    index++;
                } else {
                    sql += ", " + selectedColumn;
                }
            }
        }
        sql += " \nfrom " + tableName + " \nwhere (" + columnName + " != '') ";
        if (filters != null) {
            sql += "AND (";
            int index = 0;
            for (String filter : filters) {
                if (index == 0) {
                    sql += " \n" + columnName + " = '" + filter + "'";
                    index++;
                } else {
                    sql += " \nOR " + columnName + " = '" + filter + "'";
                }
            }
            sql += ");";
        }

        statement.execute(sql);
        return statement.getResultSet();
    }

    /**
     * Método que obtiene el curso más bajo o más alto, según el booleano, que
     * tiene la base de datos.
     * 
     * @param columnName
     *            Nombre de la columna.
     * @param tableName
     *            Nombre de la tabla.
     * @param minimo
     *            True si queremos el curso mínimo, false si queremos el curso
     *            máximo.
     * @return Curso más bajo que ha encontrado.
     * @throws SQLException
     */
    public Date getYear(String columnName, String tableName, Boolean minimo)
            throws SQLException {

        Statement statement = connection.createStatement();
        String sql = "Select " + columnName + " from " + tableName + ";";
        ResultSet result = statement.executeQuery(sql);

        // Capturamos los metadatos de la tabla
        ResultSetMetaData rmeta = result.getMetaData();
        int numColumns = rmeta.getColumnCount();
        List<Date> listadoFechas = new ArrayList<Date>();

        // Recorremos las filas del cursor
        while (result.next()) {
            for (int i = 1; i <= numColumns; ++i) {
                listadoFechas.add(transform(result.getString(i)));
            }
        } // while
        result.close();
        if (minimo) {
            return Collections.min(listadoFechas);
        } else {
            return Collections.max(listadoFechas);
        }
    }

    /**
     * Método que obtiene la fecha de asignación, la fecha de presentación, el
     * total de días y la nota respectiva del proyecto.
     * 
     * @param columnName
     *            Nombre de la columna de la fecha de asignación.
     * @param columnName2
     *            Nombre de la columna de la fecha de presentación.
     * @param columnName3
     *            Nombre de la columna del total de días.
     * @param columnName4
     *            Nombre de la columna de la nota del proyecto.
     * @param tableName
     *            Nombre de la tabla.
     * @param curso
     *            Curso del que queremos los datos.
     * @return Un lista con todos los datos que hemos solicitado.
     * @throws SQLException
     */
    @SuppressWarnings({ "rawtypes", "unchecked" })
    public List<List> getProjectsCurso(String columnName, String columnName2,
            String columnName3, String columnName4, String tableName,
            Number curso) throws SQLException {

        Statement statement = connection.createStatement();
        List lista = new ArrayList();

        List<List> resultados = new ArrayList<List>();

        String sql = "Select " + columnName + "," + columnName2 + ","
                + columnName3 + "," + columnName4
                + ", Alumno1, Alumno2, Alumno3, Tutor1, Tutor2, Tutor3 from "
                + tableName + " where " + columnName + " like '%" + curso
                + "';";

        ResultSet result = statement.executeQuery(sql);

        while (result.next()) {

            lista = new ArrayList();
            // Fecha asignación
            lista.add(transform(result.getString(columnName)));
            // Fecha presentación
            lista.add(transform(result.getString(columnName2)));
            // Dias
            lista.add(result.getInt(columnName3));
            // Nota
            lista.add(result.getDouble(columnName4));
            // Alumno1
            lista.add(result.getString("Alumno1"));
            // Alumno2
            lista.add(result.getString("Alumno2"));
            // Alumno3
            lista.add(result.getString("Alumno3"));
            // Tutor1
            lista.add(result.getString("Tutor1"));
            // Tutor2
            lista.add(result.getString("Tutor2"));
            // Tutor3
            lista.add(result.getString("Tutor3"));
            resultados.add(lista);

        }
        result.close();

        return resultados;
    }

    /**
     * Transforma el string que le llega en un tipo Date.
     * 
     * @param g
     *            Fecha en tipo String
     * @return Fecha con formato Date
     */
    private Date transform(String g) {

        DateFormat formatter = new SimpleDateFormat("MM/DD/yyyy");

        Date date = null;
        try {
            date = (Date) formatter.parse(g);
        } catch (ParseException e) {
            LOGGER.error(e);
        }
        return date;
    }

    /**
     * Destructor elimina la conexión al sistema de acceso a datos.
     * 
     **/
    @Override
    public void finalize() throws Throwable {
        try {
            connection.close();
        } catch (SQLException e) {
            LOGGER.error(e);
        }
        super.finalize();
    }

}
