# TFG-PageRank-Aplicaciones
Código y datos del Trabajo de Fin de Grado en Matemáticas: Aplicaciones del algoritmo PageRank al circuito de tenis ATP y a la red de carriles bici de Sevilla.

## 📂 Estructura del Proyecto

He organizado los archivos según el área de estudio para facilitar su comprensión:

### 🎾 1. Análisis del Ranking ATP (Tenis)
Estudio y ordenación de jugadores utilizando estructuras de grafos y métodos de centralidad.
* `grafo_atp.m`: Construye la red de enfrentamientos y jugadores a partir de los datos de la ATP.
* `atp_ranking_analysis.m`: Script principal para analizar el ranking de tenis.
* `atp_ranking_analysisponderado.m`: Análisis del ranking aplicando pesos o ponderaciones en las conexiones (aristas).
* `metodos_comparados_atp.m`: Comparación de diferentes algoritmos y métricas para determinar el ranking de los jugadores.
* `experimento_estados_absorbentes.m`: Simulación y análisis de cadenas de Markov con estados absorbentes sobre grafos.

### 🚲 2. Red de Carriles Bici de Sevilla
Estudio de conectividad y accesibilidad de la red ciclista urbana.
* `sevilla_bicis_analysisC.m`: Script de MATLAB para procesar y analizar la red de carriles bici de Sevilla utilizando la matriz de adyacencia referida a las calles.
* `sevilla_bicis_analysisN.m`: Script de MATLAB para procesar y analizar la red de carriles bici de Sevilla utilizando la matriz de adyacencia referida a los nodos.
* `AyudaVisualCarrilesBicis.pdf`: Documento PDF pintado para entender el análisis realizado.

### 📊 3. Modelos de Grafos y Experimentos Generales
Modelos matemáticos y simulación de procesos sobre redes.
* `LPIM.m`: Matriz LPIM sacada de `AyudaVisualCarrilesBicis.pdf`
* `grafoPPAM.m`: Generación del grafo basado en el modelo sevilla_bicis_analysisC.m
* `grafoLLAM.m`: Generación del grafo basado en el modelo sevilla_bicis_analysisN.m
* `PPAMLLAM.m`: Script donde se saca las matrices de adyacencia PPAM Y LLAM a partir de LPIM.
* `imagengrafoD.jpg`: Imagen exportada que muestra la visualización de uno de los grafos resultantes.

---

## 🛠️ Requisitos e Instalación

Para poder ejecutar estos scripts, necesitarás:
* **MATLAB** (Se recomienda una versión reciente).
  
