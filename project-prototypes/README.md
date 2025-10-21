# Prototipos de Extracción de Puntos de Interés

Este directorio contiene los prototipos utilizados para la extracción de puntos de interés turísticos mediante el uso de Modelos de Lenguaje (LLM). Se incluyen dos enfoques principales: un cuaderno de Jupyter que detalla la construcción de prompts, y un prototipo desarrollado en LangFlow.

## Contenido

- `prompting.ipynb`: Cuaderno interactivo de Jupyter que guía paso a paso la creación de prompts para extraer puntos de interés de una ciudad. Utiliza un modelo de lenguaje grande (LLM) para devolver un JSON que incluye:
  - **Nombre del punto de interés**
  - **Coordenadas GPS**
  - **Descripción**
  - **URL relacionada**
  
- `prototipo_langflow.json`: Modelo creado en LangFlow con el mismo objetivo de extraer puntos de interés. Este archivo define el flujo y los pasos que sigue el modelo para procesar los datos de entrada y devolver información relevante sobre puntos turísticos.

## Objetivo

Ambos prototipos están diseñados para obtener información detallada de lugares de interés en cualquier ciudad, que luego puede ser utilizada para enriquecer las rutas turísticas generadas por la aplicación.

## Uso

1. **prompting.ipynb**: Abre el archivo en Jupyter Notebook y sigue las instrucciones para ejecutar los pasos de creación de prompts y obtención de resultados.
2. **prototipo_langflow.json**: Importa el archivo en la herramienta [LangFlow](https://github.com/logspace-ai/langflow) para visualizar y ejecutar el flujo de trabajo predefinido.

## Requisitos

- Un entorno de Jupyter para ejecutar `prompting.ipynb`.
- LangFlow instalado para utilizar el archivo JSON de flujo de trabajo.

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](../LICENSE) para más detalles.
