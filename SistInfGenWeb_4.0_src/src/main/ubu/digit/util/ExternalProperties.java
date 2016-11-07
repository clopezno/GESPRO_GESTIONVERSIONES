package ubu.digit.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.apache.log4j.Logger;

/**
 * Clase para la obtención de los valores de las propiedades.
 * 
 * @author Beatriz Zurera Martínez-Acitores.
 * @since 3.0
 */
public class ExternalProperties {

    /**
     * Logger de la clase.
     */
    private static final Logger LOGGER = Logger.getLogger(ExternalProperties.class);

    /**
     * Propiedad.
     */
    private static final Properties PROPERTIES = new Properties();

    /**
     * Fichero del que leeremos las propiedades.
     */
    private static String FILE;

    /**
     * Instancia que tendrá la propiedad.
     */
    private static ExternalProperties instance;

    /**
     * Constructor.
     */
    private ExternalProperties() {

        InputStream inputStream = null;
        try {
            inputStream = new FileInputStream(FILE);
            PROPERTIES.load(inputStream);
        } catch (IOException e) {
            LOGGER.error("", e);
        }
    }

    /**
     * Método singleton para obtener la instancia de la clase fachada.
     */
    public static ExternalProperties getInstance(String propFileName) {
        if (instance == null) {
            FILE = propFileName;
            instance = new ExternalProperties();
        }
        return instance;
    }

    /**
     * Método que obtiene el valor de la propiedad que se pasa.
     * 
     * @param key
     *            Propiedad de la cual queremos conocer el valor.
     * @return El valor de la propiedad.
     */
    public String getSetting(String key) {
        return PROPERTIES.getProperty(key).trim();
    }

}