# Mitos y verdades sobre la liberalización chilena
# Claves para el debate (IES) | Ramón Jara López
#
# Reproduce los siete gráficos del documento: WVS (1-2) y Bicentenario (3-7).
# La sección sobre élites utiliza el informe COES; no se calcula con estas bases.
#
# EJECUCIÓN
# 1. Trabajar desde la carpeta de este Claves (directorio de trabajo en RStudio).
# 2. Guardar las dos bases procesadas en data/processed/, o editar las rutas.
# 3. Instalar una vez: install.packages(c("dplyr", "tidyr", "haven",
#                                         "ggplot2", "scales"))
# 4. Ejecutar source("script_01.R", encoding = "UTF-8").
# Los siete gráficos se guardan como PNG en outputs/graficos/.
#
# ALCANCE
# Este script parte de bases procesadas; no reconstruye su preparación original.
# WVS: mediciones chilenas entre 1990 y 2018.
# Bicentenario: mediciones entre 2006 y 2024 disponibles para cada pregunta.
# Se usan respuestas válidas y ponderadores positivos y finitos.
# Los porcentajes se calculan dentro de cada año y materia, excluyendo no respuesta.
# Los promedios describen la codificación ordinal; no suponen equivalencia
# entre las escalas de WVS y Bicentenario. No se estiman efectos de las leyes.

# 1. Preparación ---------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(haven)
  library(ggplot2)
})

ruta_wvs <- file.path("data", "processed", "WVS_Chile_clean.dta")
ruta_bic <- file.path("data", "processed", "bicentenario_chile.dta")
carpeta_salida <- file.path("outputs", "graficos")

archivos_faltantes <- c(ruta_wvs, ruta_bic)[!file.exists(c(ruta_wvs, ruta_bic))]
if (length(archivos_faltantes) > 0) {
  stop("Faltan bases procesadas: ", paste(archivos_faltantes, collapse = ", "),
       ". Revise las rutas y el directorio de trabajo.")
}

comprobar_columnas <- function(base, columnas, nombre) {
  faltantes <- setdiff(columnas, names(base))
  if (length(faltantes) > 0) {
    stop(nombre, ": faltan columnas: ", paste(faltantes, collapse = ", "))
  }
}

wvs <- read_dta(ruta_wvs)
bic <- read_dta(ruta_bic)
comprobar_columnas(wvs, c("S020", "S017", "F118", "F120", "F121"), "WVS")
comprobar_columnas(bic, c("ano", "ponderador", "op_matr7", "op_matr11", "op_aborto"), "Bicentenario")

# 2. WVS: justificación de las prácticas ---------------------------------------
# Escala original: 1 = nunca justificable; 10 = siempre justificable.

wvs_long <- wvs %>%
  transmute(
    anio = as.numeric(S020),
    ponderador = as.numeric(S017),
    Homosexualidad = as.numeric(F118),
    Aborto = as.numeric(F120),
    Divorcio = as.numeric(F121)
  ) %>%
  pivot_longer(
    cols = c(Homosexualidad, Aborto, Divorcio),
    names_to = "tema",
    values_to = "justificacion"
  ) %>%
  filter(
    !is.na(justificacion),
    is.finite(ponderador), ponderador > 0,
    anio >= 1990, anio <= 2018,
    justificacion >= 1,
    justificacion <= 10
  ) %>%
  mutate(
    tema = factor(
      tema,
      levels = c("Aborto", "Divorcio", "Homosexualidad")
    )
  )

resumen_wvs <- wvs_long %>%
  group_by(anio, tema) %>%
  summarise(media = weighted.mean(justificacion, ponderador), .groups = "drop")

# Gráfico 1. Promedios WVS

colores <- c(
  "Aborto" = "#D55E00",
  "Divorcio" = "#0072B2",
  "Homosexualidad" = "#009E73"
)

grafico_medias_wvs <- ggplot(
  resumen_wvs,
  aes(x = anio, y = media, color = tema, group = tema)
) +
  geom_vline(xintercept = 2004, linetype = "dashed", linewidth = .4) +
  geom_vline(xintercept = 2017, linetype = "dashed", linewidth = .4) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.8) +
  annotate(
    "text",
    x = 2004,
    y = 9.5,
    label = "Ley de Matrimonio Civil\n2004",
    hjust = 1.05,
    size = 3
  ) +
  annotate(
    "text",
    x = 2017,
    y = 9.5,
    label = "Aborto en tres causales\n2017",
    hjust = 1.05,
    size = 3
  ) +
  scale_color_manual(values = colores) +
  scale_x_continuous(
    breaks = c(1990, 1996, 2000, 2006, 2012, 2018)
  ) +
  scale_y_continuous(
    breaks = 1:10,
    limits = c(1, 10)
  ) +
  labs(
    x = NULL,
    y = "Justificación promedio",
    color = NULL,
    caption = paste(
      "Elaboración propia a partir de World Values Survey.",
      "Instituto de Estudios de la Sociedad (IES)"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# Gráfico 2. Distribuciones WVS

dist_temas <- wvs_long %>%
  group_by(anio, tema, justificacion) %>%
  summarise(
    peso = sum(ponderador),
    .groups = "drop_last"
  ) %>%
  mutate(
    prop = peso / sum(peso)
  ) %>%
  ungroup()

grafico_distribucion_wvs <- dist_temas %>%
  ggplot(
    aes(x = justificacion, y = prop)
  ) +
  geom_col() +
  facet_grid(tema ~ anio) +
  scale_x_continuous(
    breaks = c(1, 5, 10)
  ) +
  scale_y_continuous(
    labels = scales::percent_format()
  ) +
  labs(
    x = "Nivel de justificación",
    y = "% de respuestas",
    caption = paste(
      "Elaboración propia a partir de World Values Survey.",
      "Instituto de Estudios de la Sociedad (IES)"
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank()
  )

# 3. Bicentenario: reconocimiento de derechos ----------------------------------
# Se conserva la armonización del script original:
# - 2015: op_matr7 y op_matr11 intercambiadas en esta base procesada.
# - 2021: categorías invertidas en esta base procesada.
# Estas reglas deben contrastarse con los cuestionarios si se cambia de base.
# No aplicar sobre una base que ya haya corregido estos mismos problemas.
# Escala armonizada de matrimonio/adopción: 1 = muy en desacuerdo,
# 3 = ni de acuerdo ni en desacuerdo; 5 = muy de acuerdo.
# Aborto original: 3 = ninguna, 2 = algunas, 1 = cualquier circunstancia.

bic <- bic %>%
  filter(ano >= 2006, ano <= 2024) %>%
  mutate(
    ponderador = as.numeric(ponderador),

    # Matrimonio homosexual
    matr7_corr = case_when(
      ano == 2015 ~ as.numeric(op_matr11),
      ano == 2021 ~ 6 - as.numeric(op_matr7),
      TRUE        ~ as.numeric(op_matr7)
    ),

    # Adopción homoparental
    matr11_corr = case_when(
      ano == 2015 ~ as.numeric(op_matr7),
      ano == 2021 ~ 6 - as.numeric(op_matr11),
      TRUE        ~ as.numeric(op_matr11)
    ),

    # Escalas analíticas:
    # 1 = Muy en desacuerdo
    # 5 = Muy de acuerdo

    matrimonio = 6 - matr7_corr,
    adopcion = 6 - matr11_corr,

    # Aborto: índice de 1 (ninguna) a 3 (cualquiera), creado antes del resumen.
    aborto_indice = case_when(
      as.numeric(op_aborto) %in% 1:3 ~ 4 - as.numeric(op_aborto),
      TRUE ~ NA_real_
    ),

    # Aborto: variable categórica

    aborto = factor(
      as.numeric(op_aborto),
      levels = c(3, 2, 1),
      labels = c(
        "Bajo ninguna circunstancia",
        "Solo bajo algunas circunstancias",
        "Bajo cualquier circunstancia"
      )
    )
  )

# Gráfico 3. Posición promedio sobre aborto

resumen_aborto_bic <- bic %>%
  filter(
    !is.na(aborto_indice),
    is.finite(ponderador), ponderador > 0
  ) %>%
  group_by(ano) %>%
  summarise(
    media = weighted.mean(aborto_indice, ponderador),
    .groups = "drop"
  )

grafico_media_aborto_bic <- ggplot(
  resumen_aborto_bic,
  aes(x = ano, y = media)
) +

  # Ley de aborto en tres causales
  geom_vline(xintercept = 2017, linetype = "dashed", linewidth = .4) +

  annotate(
    "text",
    x = 2017,
    y = 2.85,
    label = "Aborto en tres causales\n2017",
    hjust = 1.05,
    size = 3
  ) +

  geom_line(linewidth = 1.1) +

  geom_point(size = 2.8) +

  scale_x_continuous(
    breaks = sort(
      unique(resumen_aborto_bic$ano)
    )
  ) +

  scale_y_continuous(
    limits = c(1, 3),
    breaks = 1:3,
    labels = c("Ninguna", "Algunas", "Cualquiera")
  ) +

  labs(
    x = NULL,
    y = "Posición promedio frente al aborto",
    caption = paste(
      "Índice ordinal: 1 = bajo ninguna circunstancia;",
      "2 = solo bajo algunas circunstancias;",
      "3 = bajo cualquier circunstancia.",
      "\nElaboración propia a partir de Encuesta Bicentenario UC.",
      "Promedios ponderados."
    )
  ) +

  theme_minimal(base_size = 12) +

  theme(
    panel.grid.minor = element_blank()
  )

# Gráfico 4. Distribución sobre aborto

dist_aborto_bic <- bic %>%
  filter(
    !is.na(aborto),
    is.finite(ponderador), ponderador > 0
  ) %>%
  group_by(ano, aborto) %>%
  summarise(
    peso = sum(ponderador),
    .groups = "drop_last"
  ) %>%
  mutate(
    prop = peso / sum(peso)
  ) %>%
  ungroup()

dist_aborto_bic <- dist_aborto_bic %>%
  mutate(
    aborto_grafico = factor(
      aborto,
      levels = c(
        "Bajo ninguna circunstancia",
        "Solo bajo algunas circunstancias",
        "Bajo cualquier circunstancia"
      ),
      labels = c("Ninguna", "Algunas", "Cualquiera")
    )
  )

grafico_aborto_bic <- ggplot(
  dist_aborto_bic,
  aes(x = aborto_grafico, y = prop)
) +
  geom_col(width = .7) +
  facet_wrap(~ ano, ncol = 5) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, 0.25),
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    x = "Circunstancias en que se reconoce el derecho al aborto",
    y = "% de respuestas",
    caption = paste(
      "Categorías: bajo ninguna circunstancia, solo bajo algunas",
      "circunstancias y bajo cualquier circunstancia.",
      "\nElaboración propia a partir de Encuesta Bicentenario UC.",
      "Porcentajes ponderados."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

# Gráfico 5. Promedios de matrimonio y adopción

bic_derechos <- bic %>%
  transmute(ano, ponderador, matrimonio, adopcion) %>%
  pivot_longer(
    cols = c(matrimonio, adopcion),
    names_to = "tema",
    values_to = "respuesta"
  ) %>%
  filter(
    !is.na(respuesta),
    is.finite(ponderador), ponderador > 0,
    respuesta >= 1,
    respuesta <= 5
  ) %>%
  mutate(
    tema = factor(
      tema,
      levels = c("matrimonio", "adopcion"),
      labels = c("Matrimonio", "Adopción")
    )
  )

resumen_derechos_bic <- bic_derechos %>%
  group_by(ano, tema) %>%
  summarise(media = weighted.mean(respuesta, ponderador), .groups = "drop")

grafico_medias_bic <- ggplot(
  resumen_derechos_bic,
  aes(x = ano, y = media, color = tema, group = tema)
) +

  # Punto medio de la escala
  geom_hline(yintercept = 3, linetype = "dotted", linewidth = .4, color = "grey50") +

  # Hito legal
  geom_vline(xintercept = 2022, linetype = "dashed", linewidth = .4) +

  geom_line(linewidth = 1.1) +

  geom_point(size = 2.8) +

  annotate(
    "text",
    x = 2022,
    y = 4.7,
    label = "Matrimonio igualitario\n2022",
    hjust = 1.05,
    size = 3
  ) +

  scale_y_continuous(
    breaks = 1:5,
    limits = c(1, 5)
  ) +

  scale_x_continuous(
    breaks = sort(
      unique(resumen_derechos_bic$ano)
    )
  ) +

  labs(
    x = NULL,
    y = "Nivel promedio de acuerdo",
    color = NULL,
    caption = paste(
      "Escala de 1 a 5: valores más altos indican mayor acuerdo.",
      "\nElaboración propia a partir de Encuesta Bicentenario UC.",
      "Instituto de Estudios de la Sociedad (IES)."
    )
  ) +

  theme_minimal(base_size = 12) +

  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# Gráficos 6 y 7. Distribuciones de matrimonio y adopción

dist_derechos_bic <- bic_derechos %>%
  group_by(ano, tema, respuesta) %>%
  summarise(
    peso = sum(ponderador),
    .groups = "drop_last"
  ) %>%
  mutate(
    prop = peso / sum(peso)
  ) %>%
  ungroup()

grafico_dist_matrimonio_bic <- dist_derechos_bic %>%
  filter(tema == "Matrimonio") %>%
  ggplot(
    aes(x = respuesta, y = prop)
  ) +
  geom_col(width = .7) +
  facet_wrap(~ ano, ncol = 5) +
  scale_x_continuous(breaks = 1:5) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, 0.25),
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    x = "Nivel de acuerdo (Matrimonio)",
    y = "% de respuestas",
    caption = paste(
      "1 = Muy en desacuerdo; 3 = Ni de acuerdo ni en desacuerdo;",
      "5 = Muy de acuerdo.",
      "\nElaboración propia a partir de Encuesta Bicentenario UC.",
      "Porcentajes ponderados."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank()
  )

grafico_dist_adopcion_bic <- dist_derechos_bic %>%
  filter(tema == "Adopción") %>%
  ggplot(
    aes(x = respuesta, y = prop)
  ) +
  geom_col(width = .7) +
  facet_wrap(~ ano, ncol = 5) +
  scale_x_continuous(breaks = 1:5) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, 0.25),
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    x = "Nivel de acuerdo (Adopción)",
    y = "% de respuestas",
    caption = paste(
      "1 = Muy en desacuerdo; 3 = Ni de acuerdo ni en desacuerdo;",
      "5 = Muy de acuerdo.",
      "\nElaboración propia a partir de Encuesta Bicentenario UC.",
      "Porcentajes ponderados."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank()
  )

# 4. Exportar los siete gráficos -----------------------------------------------
# Los nombres siguen la numeración del documento.

dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)
graficos <- list(
  "01_wvs_promedios" = grafico_medias_wvs,
  "02_wvs_distribuciones" = grafico_distribucion_wvs,
  "03_bicentenario_aborto_promedio" = grafico_media_aborto_bic,
  "04_bicentenario_aborto_distribucion" = grafico_aborto_bic,
  "05_bicentenario_matrimonio_adopcion_promedios" = grafico_medias_bic,
  "06_bicentenario_matrimonio_distribucion" = grafico_dist_matrimonio_bic,
  "07_bicentenario_adopcion_distribucion" = grafico_dist_adopcion_bic
)
alturas <- c(6, 8, 6, 8, 6, 8, 8)
for (i in seq_along(graficos)) {
  ggsave(
    filename = file.path(carpeta_salida, paste0(names(graficos)[i], ".png")),
    plot = graficos[[i]], width = 13, height = alturas[i],
    units = "in", dpi = 300, bg = "white"
  )
}
message("Gráficos guardados en: ", normalizePath(carpeta_salida))
