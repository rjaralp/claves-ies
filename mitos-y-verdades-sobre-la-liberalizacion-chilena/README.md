# Mitos y verdades sobre la liberalización chilena

**Ramón Jara López**  
**Claves para el debate — Instituto de Estudios de la Sociedad (IES)**

Esta carpeta contiene el código del análisis descriptivo utilizado en el documento *Mitos y verdades sobre la liberalización chilena*. Se examinan los cambios en la justificación de distintas prácticas y en el apoyo al reconocimiento de derechos en Chile, considerando tanto la evolución de los promedios como la distribución de las respuestas.

## Fuentes de información

El análisis utiliza dos fuentes:

- **Encuesta Mundial de Valores (WVS):** mediciones chilenas comprendidas entre 1990 y 2018. Se analizan las preguntas sobre justificación del aborto, la homosexualidad y el divorcio.
- **Encuesta Bicentenario UC:** mediciones disponibles entre 2006 y 2024. Se examinan las opiniones sobre el derecho al aborto, el matrimonio entre personas del mismo sexo y la adopción homoparental. La disponibilidad de años varía según la pregunta.

El documento también utiliza resultados publicados en el informe del **Estudio COES de la Élite en Chile**. Esa sección se basa en las cifras del informe y no en un procesamiento de sus microdatos. Por ello, sus resultados no se calculan en este script.

## Contenido y alcance del script

El archivo `script_01.R` contiene la selección de variables, las recodificaciones, el tratamiento de respuestas no válidas, el cálculo de estadísticas ponderadas y la elaboración de los siete gráficos del documento.

El script parte de dos bases previamente procesadas:

- `WVS_Chile_clean.dta`
- `bicentenario_chile.dta`

La construcción de estos archivos a partir de las bases originales no está incluida en este script. En particular, se presupone que la base WVS contiene únicamente observaciones de Chile y que las mediciones de Bicentenario ya están reunidas en un archivo común. El código permite reproducir el análisis desde esos archivos de entrada.

## Preparación de los datos

### Encuesta Mundial de Valores

Se utilizan las siguientes variables:

| Variable de entrada | Contenido |
| --- | --- |
| `S020` | Año de la encuesta |
| `S017` | Ponderador |
| `F118` | Justificación de la homosexualidad |
| `F120` | Justificación del aborto |
| `F121` | Justificación del divorcio |

Las variables se convierten a formato numérico y se reorganizan en una base larga: cada entrevistado puede aportar una respuesta por materia.

Se conservan las observaciones comprendidas entre 1990 y 2018 con respuestas entre **1 y 10**, donde 1 corresponde a «nunca justificable» y 10 a «siempre justificable». Se excluyen los valores ausentes y los códigos fuera de ese rango, así como las observaciones cuyo ponderador sea ausente, infinito, nulo o negativo.

La selección se realiza por pregunta. Una persona que no responde sobre aborto puede contribuir al análisis de divorcio u homosexualidad si tiene respuestas válidas en esas materias.

### Encuesta Bicentenario

Se utilizan las siguientes variables de la base procesada:

| Variable de entrada | Contenido utilizado |
| --- | --- |
| `ano` | Año de la encuesta |
| `ponderador` | Ponderador |
| `op_aborto` | Posición frente al derecho al aborto |
| `op_matr7` | Ítem utilizado para matrimonio, sujeto a la armonización descrita abajo |
| `op_matr11` | Ítem utilizado para adopción, sujeto a la armonización descrita abajo |

Se conservan las mediciones comprendidas entre 2006 y 2024.

#### Matrimonio y adopción

El script mantiene dos ajustes de la versión original del análisis:

- **2015:** intercambia `op_matr7` y `op_matr11` para asignar las respuestas a matrimonio y adopción.
- **2021:** invierte la codificación de ambos ítems mediante la operación `6 - respuesta`.

Estos ajustes corresponden a la organización de la base procesada utilizada. Si se emplea otro archivo, deben verificarse sus códigos y etiquetas antes de aplicar las mismas operaciones. No deben repetirse sobre una base que ya incorpore esas correcciones.

Tras la armonización, ambas variables se orientan de la siguiente manera:

| Valor analítico | Categoría |
| --- | --- |
| 1 | Muy en desacuerdo |
| 2 | En desacuerdo |
| 3 | Ni de acuerdo ni en desacuerdo |
| 4 | De acuerdo |
| 5 | Muy de acuerdo |

Se conservan las respuestas entre 1 y 5 y los ponderadores positivos y finitos. Los cálculos se realizan por año y materia, utilizando las respuestas válidas de cada pregunta.

#### Aborto

La variable `op_aborto` se recodifica de acuerdo con la siguiente correspondencia:

| Código de entrada | Categoría | Valor analítico |
| --- | --- | --- |
| 3 | Bajo ninguna circunstancia | 1 |
| 2 | Solo bajo algunas circunstancias | 2 |
| 1 | Bajo cualquier circunstancia | 3 |

Los códigos distintos de 1, 2 y 3 se tratan como valores ausentes. Se utilizan dos representaciones de esta variable: una categórica para mostrar la distribución de las respuestas y otra numérica, denominada `aborto_indice`, para calcular el promedio.

## Ponderación y estadísticas descriptivas

Todos los promedios y porcentajes utilizan el ponderador contenido en la respectiva base. El script no construye nuevos factores de expansión.

Para cada combinación de año y materia:

- El **promedio ponderado** se calcula multiplicando cada respuesta por su ponderador, sumando esos productos y dividiendo por la suma de los ponderadores.
- La **proporción de cada categoría** se calcula dividiendo la suma de los ponderadores de quienes eligieron esa respuesta por la suma de los ponderadores de todas las respuestas válidas a la pregunta.

Los porcentajes se refieren, por tanto, a las respuestas válidas de cada año y materia. Las observaciones sin respuesta válida no forman parte del denominador. No se realiza imputación de datos.

Los promedios resumen la posición de las respuestas bajo la codificación adoptada. Dado el carácter ordinal de las escalas, deben interpretarse junto con las distribuciones. En particular, un promedio cercano a 2 en la pregunta sobre aborto de Bicentenario no implica por sí solo que la mayoría haya escogido «solo bajo algunas circunstancias»: distintas distribuciones pueden producir un promedio semejante.

El análisis es descriptivo. No se estiman modelos explicativos, pruebas de significación ni intervalos de confianza que incorporen el diseño muestral.

## Gráficos

| Número en el documento | Contenido | Archivo exportado |
| --- | --- | --- |
| 1 | Promedios de justificación de aborto, divorcio y homosexualidad en WVS | `01_wvs_promedios.png` |
| 2 | Distribuciones de respuestas por materia y año en WVS | `02_wvs_distribuciones.png` |
| 3 | Posición promedio sobre aborto en Bicentenario | `03_bicentenario_aborto_promedio.png` |
| 4 | Distribución de respuestas sobre aborto en Bicentenario | `04_bicentenario_aborto_distribucion.png` |
| 5 | Promedios de acuerdo con matrimonio y adopción en Bicentenario | `05_bicentenario_matrimonio_adopcion_promedios.png` |
| 6 | Distribución de respuestas sobre matrimonio en Bicentenario | `06_bicentenario_matrimonio_distribucion.png` |
| 7 | Distribución de respuestas sobre adopción en Bicentenario | `07_bicentenario_adopcion_distribucion.png` |

Las líneas que unen las mediciones sirven como guía visual. No representan observaciones para los años sin encuesta. Los hitos legales señalados en algunos gráficos son referencias temporales; el análisis no identifica efectos causales de esas leyes.

## Comparabilidad e interpretación

WVS y Bicentenario permiten examinar dimensiones relacionadas del cambio cultural. WVS pregunta por la justificación de determinadas prácticas; los ítems seleccionados de Bicentenario consultan opiniones sobre el reconocimiento de derechos.

Las encuestas difieren en las preguntas, las escalas, las materias y los períodos cubiertos. Sus promedios y porcentajes no se interpretan como medidas directamente equivalentes. Incluso en aborto, presente en ambas fuentes, la justificación de la práctica y el reconocimiento del derecho corresponden a juicios distintos.

Las mediciones se analizan como muestras sucesivas. El script describe cambios agregados y no sigue la trayectoria de las mismas personas. Tampoco permite establecer cómo un mismo individuo relaciona sus valoraciones morales con sus opiniones sobre derechos.

## Reproducción del análisis

### Archivos necesarios

Dentro de la carpeta de este documento deben estar disponibles:

| Ruta | Contenido |
| --- | --- |
| `script_01.R` | Código del análisis |
| `data/processed/WVS_Chile_clean.dta` | Base procesada de WVS Chile |
| `data/processed/bicentenario_chile.dta` | Base procesada de Bicentenario |

Los nombres de los archivos y de sus variables deben coincidir con los utilizados en el script. Las rutas pueden modificarse al comienzo del código.

### Ejecución

1. Abrir R o RStudio.
2. Establecer como directorio de trabajo la carpeta `mitos-y-verdades-sobre-la-liberalizacion-chilena`.
3. Instalar, si es necesario, los paquetes `dplyr`, `tidyr`, `haven`, `ggplot2` y `scales`, ejecutando:  
   `install.packages(c("dplyr", "tidyr", "haven", "ggplot2", "scales"))`
4. Ejecutar:  
   `source("script_01.R", encoding = "UTF-8")`

El script comprueba la existencia de los archivos y de las columnas requeridas. Luego realiza el procesamiento y guarda los siete gráficos en `outputs/graficos/`, en formato PNG y a 300 dpi. La carpeta de salida se crea automáticamente.

Para registrar las versiones de R y de los paquetes utilizadas en una ejecución, puede consultarse `sessionInfo()`.
