# Aplicaciones del Algoritmo PageRank: Tenis ATP y Red de Carriles Bici

Este repositorio contiene el soporte computacional de mi **Trabajo de Fin de Grado en Matemáticas**. El objetivo es explorar cómo el algoritmo PageRank, diseñado originalmente para ordenar la web, puede aplicarse para analizar la jerarquía en el deporte profesional y la eficiencia en redes de transporte urbano.

## 📂 Estructura del Código

He organizado los scripts de MATLAB para que sigan el orden de la investigación:

### 🎾 1. Análisis del Ranking ATP
En este bloque estudio la red de enfrentamientos del tenis profesional masculino desde el año 2000 hasta el 2024.

* **`atp_ranking_analisis.m`**: Script principal que construye el grafo de jugadores y calcula el ranking de prestigio estándar.
* **`atp_ranking_analisisponderado.m`**: Una versión avanzada donde cada victoria se pesa según el diferencial de puntos del partido, permitiendo un análisis más profundo de la dominancia de cada jugador.
* **`metodos_comparados_atp.m`**: Comparativa entre tres modelos: Perron-Frobenius, PageRank ($\alpha=0.85$) y el Método de Keener, analizando cómo varía el Top 10 según el algoritmo.
* **`experimento_estados_absorbentes.m`**: Simulación para comprobar la robustez de la red frente a nodos sumideros (jugadores invictos) y cómo el algoritmo corrige estas anomalías.
* **`grafo_atp.m`**: Script dedicado a la generación de gráficos, creando representaciones visuales del flujo de prestigio entre los mejores jugadores.

### 🚲 2. Red de Carriles Bici (Sevilla)
*(Próximamente)* Análisis de centralidad aplicado a la red de movilidad ciclista de la ciudad de Sevilla.

---

**Autora:** Tesa Chacón  
**Grado en Matemáticas**
