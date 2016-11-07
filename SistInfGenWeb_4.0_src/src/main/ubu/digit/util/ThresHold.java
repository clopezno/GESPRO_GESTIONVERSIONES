package ubu.digit.util;

import java.text.NumberFormat;

/**
 * Clase de utilidad para definir intervalos y operaciones algebraicas sobre
 * ellos.
 * 
 * @author Carlos López Nozal
 * @author Beatriz Zurera Martínez-Acitores
 * @since 1.5
 * @version 2.0
 * 
 */

public class ThresHold {

    /**
     * Extremo superior del intervalo
     */
    private Number max;

    /**
     * Extremo inferior del intervalo
     */
    private Number min;

    /**
     * Formatedor de los números del intervalo
     */
    private NumberFormat numberFormat;

    /**
     * Construcción de un intervalos cerrado
     * 
     * @param pMax
     *            Extremo superior del intervalo.
     * @param pMin
     *            Extremo inferior del intervalo.
     */
    public ThresHold(Number pMax, Number pMin) {
        max = pMax;
        min = pMin;
        numberFormat = NumberFormat.getInstance();
        numberFormat.setMaximumFractionDigits(2);
    }

    /**
     * Construcción de un intervalos cerrado por defecto con los extremos
     * iguales a cero.
     */
    public ThresHold() {
        max = 0;
        min = 0;
    }

    /**
     * Comprueba si un número esta contenido dentro del intervalo.
     * 
     * @param n
     *            Número a validar.
     * @return true si el número esta dentro del intervalo, false en caso
     *         contrario.
     */
    public boolean isInThreshold(Number n) {
        if ((n.doubleValue() <= max.doubleValue())
                && (n.doubleValue() >= min.doubleValue())) {
            return true;
        }
        return false;
    }

    /**
     * Comprueba si un intervalo esta contenido dentro del intervalo
     * 
     * @param t
     *            intervalo a validar.
     * @return true si el intervalo esta contenido dentro del intervalo, false
     *         en caso contrario.
     */
    public boolean isInThreshold(ThresHold t) {

        if ((t.max.doubleValue() <= max.doubleValue())
                && (t.max.doubleValue() >= min.doubleValue())
                && (t.min.doubleValue() <= max.doubleValue())
                && (t.min.doubleValue() >= min.doubleValue())) {
            return true;
        }
        return false;
    }

    /**
     * Comprueba si el intervalo ha tenido una inicialización distinta de la por
     * defecto.
     * 
     * @return true si el intervalo ha sido inicializado , false en caso
     *         contrario.
     */
    public boolean isInit() {
        return max.doubleValue() != 0 && min.doubleValue() != 0;
    }

    /**
     * Consulta el extremo superior del intervalo.
     * 
     * @return extremo superior del intervalo.
     */
    public Number getMax() {
        return max;
    }

    /**
     * Extremo inferior del intervalo
     * 
     * @return extremo superior del intervalo.
     */
    public Number getMin() {
        return min;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "[" + numberFormat.format(min.doubleValue()) + " ,"
                + numberFormat.format(max.doubleValue()) + "]";
    }
}
