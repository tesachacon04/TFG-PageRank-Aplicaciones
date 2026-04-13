% 1. Convertimos la matriz en Grafo
MiGrafo1 = digraph(PPAM); 

% 2. Dibujamos el grafo: Nodos morados (#7E2F8E) y aristas grises ([0.6 0.6 0.6])
p1 = plot(MiGrafo1, 'NodeColor', '#7E2F8E', 'EdgeColor', [0.6 0.6 0.6], 'MarkerSize', 6);

% 3. Destacamos el Nodo Exterior (ej. 72) en verde (#77AC30) y más grande
highlight(p1, 72, 'NodeColor', '#77AC30', 'MarkerSize', 11); 

% 4. Ponerlo bonito: Título y quitar ejes del fondo
title('Topología de la Red Ciclista (Grafo Primal)', 'FontSize', 14);
axis off; 

% 5. EL TRUCO DE LA LEYENDA (Marcadores invisibles para el cuadro)
hold on;
h1 = plot(NaN, NaN, 'o', 'Color', '#7E2F8E', 'MarkerFaceColor', '#7E2F8E', 'MarkerSize', 8);
h2 = plot(NaN, NaN, 'o', 'Color', '#77AC30', 'MarkerFaceColor', '#77AC30', 'MarkerSize', 10);
h3 = plot(NaN, NaN, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);
legend([h1, h2, h3], {'Nodos Interiores', 'Nodo Exterior', 'Conexiones'}, 'Location', 'best');
hold off;
