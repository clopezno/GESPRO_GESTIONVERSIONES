## Experimentación con Langflow - Eco City Tours
Para probar el prototipo se necesita:
- Un servidor con el LLM ollama instalado y funcionando en el puerto por defecto 11434 (en mi caso Ollama3.1 (8B)), se puede descargar de aquí: https://github.com/ollama/ollama o de www.ollama.com  
- Una base de datos vectorial AstraDB de la que habrá que obtener punto de acceso y token. Un buen tutorial se puede observar en la siguiente video:
https://www.youtube.com/watch?v=RWo4GDTZIsE&t=1644s 
- Como buscador en la web use Serper.dev: en el momento del desarrollo de este prototipo su uso era gratuito hasta 2.500 búsquedas al mes. Hay que darse de alta y se puede probar su funcionamiento en la web. Usa un motor google para las búsquedas.
------
## Resultados ejemplo para el prototipo

Resultado de 10 sitios para Salamanca. 


[

    {

        "name": "Plaza Mayor",

        "description": "La Plaza Mayor de Salamanca, del siglo XVIII, es una de las más bellas plazas monumentales urbanas de Europa.",

        "gps": [40.965027795465176, -5.664062074092496]

    },

    {

        "name": "Convento de la Trinidad",

        "description": "Former Palacio de Montellano adapted in the 16th century to house a Trinitarian convent.",

        "gps": [40.95432117749319, -5.664111983624511]

    },

    {

        "name": "Monasterio de Nuestra Señora de la Victoria",

        "description": "Of the Hieronymites, completed in 1513, half-destroyed by the French in the early 19th century.",

        "gps": [40.96414417944433, -5.66614599511111]

    },

    {

        "name": "Ermita de Nuestra Señora de la Misericordia",

        "description": "Small baroque temple that began to be built in 1389 in the Plaza de San Cristóbal.",

        "gps": [40.96214417944433, -5.66514599511111]

    },

    {

        "name": "Former church of las Bernardas",

        "description": "Work of Rodrigo Gil de Hontañón. Prototype of the Salamanca churches of the 16th century.",

        "gps": [40.96114417944433, -5.66414599511111]

    }

]

### Resultado para Burgos. 10 sitios con intereses: naturaleza e historia.


[

  {

    "name": "Monasterio de las Huelgas",

    "description": "El monasterio de Santa María Real de las Huelgas es un convento cisterciense de mujeres ubicado en la ciudad española de Burgos.",

    "gps": [42.316944, -3.718056]

  },

  {

    "name": "Catedral de Burgos",

    "description": "La Catedral de Santa María es una catedral gótica situada en la ciudad de Burgos, Castilla y León.",

    "gps": [42.346667, -3.700556]

  },

  {

    "name": "Paseo del Espolón",

    "description": "El Paseo del Espolón es un paseo peatonal ubicado en la ciudad de Burgos, Castilla y León.",

    "gps": [42.354722, -3.694444]

  },

  {

    "name": "Parque del Parral",

    "description": "El Parque del Parral es un parque urbano situado en el barrio homónimo de la ciudad de Burgos, Castilla y León.",

    "gps": [42.334722, -3.713056]

  },

  {

    "name": "Cartuja de Miraflores",

    "description": "La Cartuja de Miraflores es un monasterio cartujo situado en el término municipal de la ciudad española de Burgos.",

    "gps": [42.317778, -3.707222]

  },

  {

    "name": "Museo del Románico",

    "description": "El Museo del Románico es un museo ubicado en el claustro del monasterio cartujo de Miraflores.",

    "gps": [42.317778, -3.707222]

  },

  {

    "name": "Museo de la Evolución Humana",

    "description": "El Museo de la Evolución Humana es un museo ubicado en Burgos, Castilla y León.",

    "gps": [42.350556, -3.696667]

  },

  {

    "name": "Altarpiece Museum",

    "description": "El Altarpiece Museum es un museo ubicado en la ciudad de Burgos, Castilla y León.",

    "gps": [42.346667, -3.700556]

  },

  {

    "name": "Burgos Museum",

    "description": "El Museo de Burgos es un museo ubicado en la ciudad española de Burgos.",

    "gps": [42.354722, -3.694444]

  },

  {

    "name": "Cathedral Museum (Burgos)",

    "description": "El Museo Catedralicio de Burgos es un museo ubicado en la catedral gótica de Santa María.",

    "gps": [42.346667, -3.700556]

  },

  {

    "name": "La Isla",

    "description": "La Isla es un parque urbano situado en el barrio homónimo de la ciudad de Burgos, Castilla y León.",

    "gps": [42.334722, -3.713056]

  }

]

## Conclusiones
Utilizar este sistema RAG alimentado por búsquedas en internet aunque es un sistema interesante, no resulta muy práctico. Generar los embeddings para cada búsqueda resulta costoso computacionalmente. A diferencia de los sitemas RAG la recuperación de datos se realiza una vez por consulta, llegando a tardar incluso media hora según la experimentación realizada. Tiempo de espera que no compensa los resultados obtenidos. Aunque puedan ser más fiables y menos alucinados que los consultados directamente a un modelo convencional, una consulta a un modelo de 70B tarda menos en generar los resultados. 

Decidí dejar al menos 4 urls proporcionadas por serper. Los primeros resultados como suele ser natural en un buscador suelen ser resultados de wikipedia o la enciclopedia Brittanica. Esta información es muy probable que un modelo incluso los más pequeños de 3B tengan en su entrenamiento. A partir del tercer resultado se empieza a obtener información específica para el turismo que es muy probable que se tenga en cuenta para el resultado, como se puede comprobar incluso por el idioma de la respuesta ya que el componente de serper hace la llamada al API en inglés y se obtienen resultados como:         
"description": "Small baroque temple that began to be built in 1389 in the Plaza de San Cristóbal.". 
Más resultados mejorarían la originalidad de los resultados sin embargo el tiempo de trabajo y conversión vectorial de la base de datos aumentaría. Se trataba por tanto de mostrar un ejemplo de la efectividad del sistema.

En conclusión la experimentación muestra la potencia de la herramienta Langflow y su gran valor la modularidad de un sistema que permite cambiar elementos de manera mucho más sencilla que en un cuaderno Jupyter.