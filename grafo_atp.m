%% FASE 4: VISUALIZACIÓN DEL SUBGRAFO DE LA ÉLITE (TOP 10)
fprintf('\nGenerando el grafo de la élite...\n');

% 1. Extraemos los índices y nombres de los 10 mejores según PageRank
num_nodos_plot = 10;
idx_top10 = pos(1:num_nodos_plot);
nombres_top10 = jugadores_unicos(idx_top10);

% 2. Extraemos la matriz de adyacencia del Top 10
A_top10 = full(A(idx_top10, idx_top10)); 

% 3. Creamos el grafo especificando que use los valores de la matriz como pesos
[filas, cols, pesos] = find(A_top10); 
G = digraph(filas, cols, pesos, nombres_top10);

if isempty(G.Edges)
    error('No hay partidos registrados entre estos 10 jugadores en este periodo.');
end

% 4. Estética
figure('Name', 'Red de la Élite ATP', 'Color', 'w', 'Position', [100, 100, 800, 600]);

% 5. Hacemos que el grosor de la flecha dependa del número de victorias
pesos_aristas = G.Edges.Weight;
anchura_maxima = 5; 
anchuras_linea = (pesos_aristas / max(pesos_aristas)) * anchura_maxima;
anchuras_linea(anchuras_linea < 0.5) = 0.5; % Para que las líneas finas no desaparezcan

% 6. Hacemos que el tamaño de la "bola" dependa de su nota de PageRank
scores_top10 = ranking_pagerank(idx_top10);
tamanos_nodos = (scores_top10 / max(scores_top10)) * 25;
tamanos_nodos(tamanos_nodos < 8) = 8; % Tamaño mínimo

% 7. Dibujamos el grafo con forma circular para que se lea perfecto
p = plot(G, 'Layout', 'circle'); 
p.EdgeColor = [0.6 0.7 0.8];    % Flechas en azul clarito
p.LineWidth = anchuras_linea;   % Flechas más gordas si hay más victorias
p.NodeColor = [0.8 0.2 0.2];    % Nodos en rojo granate
p.MarkerSize = tamanos_nodos;   % Nodos más grandes si tienen más PageRank
p.NodeFontSize = 11;
p.NodeFontWeight = 'bold';
p.ArrowSize = 12;

title({'Flujo de Prestigio (Victorias) entre el Top 10 Histórico ATP', ' '}, 'FontSize', 14);
limites_x = xlim; 
limites_y = ylim;
xlim([limites_x(1)*1.15, limites_x(2)*1.15]);
ylim([limites_y(1)*1.15, limites_y(2)*1.15]);