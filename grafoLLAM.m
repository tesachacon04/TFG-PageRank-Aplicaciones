
MiGrafo2 = digraph(LLAM); 

% 2. Dibujamos el grafo: Nodos (Calles) en Azul (#0072BD) y aristas grises
p2 = plot(MiGrafo2, 'NodeColor', '#0072BD', 'EdgeColor', [0.6 0.6 0.6], 'MarkerSize', 6);

% 3. Título para el Grafo Dual y quitar ejes del fondo
title('Topología de la Red Ciclista (Grafo Dual)', 'FontSize', 14);
axis off; 

% 4. LA LEYENDA (Solo dos elementos esta vez)
hold on;
h1 = plot(NaN, NaN, 'o', 'Color', '#0072BD', 'MarkerFaceColor', '#0072BD', 'MarkerSize', 8);
h2 = plot(NaN, NaN, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);
legend([h1, h2], {'Calles / Tramos', 'Intersecciones'}, 'Location', 'best');
hold off;
