%%  VISUALIZACIÓN DE LA RED DE LA ÉLITE (TOP 10)
fprintf('Generando representación gráfica del subgrafo de la élite...\n');

% 1. Selección de los 10 nodos con mayor índice de PageRank
num_nodos_plot = 10;
idx_top10 = pos(1:num_nodos_plot);
nombres_top10 = jugadores_unicos(idx_top10);

% 2. Extracción de la matriz de adyacencia inducida por el Top 10
A_top10 = full(A(idx_top10, idx_top10)); 

% 3. Construcción del objeto de grafo dirigido con pesos de arista
[filas, cols, pesos] = find(A_top10); 
G = digraph(filas, cols, pesos, nombres_top10);

if isempty(G.Edges)
    error('No se han detectado enfrentamientos directos entre estos 10 jugadores en el periodo seleccionado.');
end

% 4. Configuración del lienzo de visualización
figure('Name', 'Red de la Élite ATP', 'Color', 'w', 'Position', [100, 100, 800, 600]);

% 5. Mapeo del grosor de las aristas según la intensidad de las victorias (frecuencia)
pesos_aristas = G.Edges.Weight;
anchura_maxima = 5; 
anchuras_linea = (pesos_aristas / max(pesos_aristas)) * anchura_maxima;
anchuras_linea(anchuras_linea < 0.5) = 0.5; % Grosor mínimo para asegurar visibilidad

% 6. Mapeo del tamaño de los nodos según su puntuación de PageRank
scores_top10 = ranking_pagerank(idx_top10);
tamanos_nodos = (scores_top10 / max(scores_top10)) * 25;
tamanos_nodos(tamanos_nodos < 8) = 8; % Tamaño mínimo de marcador

% 7. Representación del grafo mediante disposición circular (Layout Circle)
p = plot(G, 'Layout', 'circle'); 

% 8. Ajustes estéticos finales para la exportación de la imagen
p.EdgeColor = [0.6 0.7 0.8];    % Tono azulado para las conexiones
p.LineWidth = anchuras_linea;   % Grosor proporcional a los enfrentamientos
p.NodeColor = [0.8 0.2 0.2];    % Tono granate para destacar los nodos
p.MarkerSize = tamanos_nodos;   % Diámetro proporcional a la importancia estructural
p.NodeFontSize = 11;
p.NodeFontWeight = 'bold';
p.ArrowSize = 12;

% 9. Títulos y ajuste de márgenes para evitar el corte de etiquetas
title({'Flujo de Prestigio (Victorias) entre el Top 10 Histórico ATP', ' '}, 'FontSize', 14);
limites_x = xlim; 
limites_y = ylim;
xlim([limites_x(1)*1.15, limites_x(2)*1.15]);
ylim([limites_y(1)*1.15, limites_y(2)*1.15]);