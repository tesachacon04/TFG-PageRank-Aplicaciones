% =========================================================================
% VISUALIZACIÓN: TOPOLOGÍA DE LA RED CICLISTA (Grafo Dual - Carriles)
% =========================================================================
figure('Color', 'w'); 

% 1. Convertimos la matriz en Grafo
MiGrafo2 = digraph(LLAM); 

% 2. Dibujamos el grafo: Nodos (Vías) en Azul y aristas grises
p2 = plot(MiGrafo2, 'NodeColor', '#0072BD', 'EdgeColor', [0.6 0.6 0.6], 'MarkerSize', 6);

% 3. Título para el Grafo Dual y quitar ejes del fondo
title('Topología de la Red Ciclista (Grafo Dual)', 'FontSize', 14);
axis off; 

% 4. LA LEYENDA
hold on;
% Nodo azul: Representa la calle/tramo
h1 = plot(NaN, NaN, 'o', 'Color', '#0072BD', 'MarkerFaceColor', '#0072BD', 'MarkerSize', 8);
% Línea gris: Representa la intersección que conecta dos calles
h2 = plot(NaN, NaN, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);

legend([h1, h2], {'Carriles bici / Tramos (Nodos)', 'Intersecciones (Aristas)'}, 'Location', 'best');
hold off;