%% COMPARACIÓN DE MÉTODOS DE RANKING
%HAY QUE EJECUTARLO DESPUES DEL ARCHIVO atp_ranking_analisis.m
% 1. PREPARACIÓN DE LA MATRIZ DE TRANSICIÓN
% Se normaliza la matriz de adyacencia A para obtener las probabilidades de flujo P
sum_columnas = sum(A, 1);
sum_columnas(sum_columnas == 0) = 1; 
P = A ./ sum_columnas;
N = size(P, 1);

%% MÉTODO 1: PERRON-FROBENIUS (EL MODELO PURO)
% Se calcula el autovector principal de la matriz P sin añadir saltos aleatorios.
% Representa la importancia teórica basada exclusivamente en la red de victorias.
[V, D] = eigs(P, 1); 
ranking_perron = abs(V);
ranking_perron = ranking_perron / sum(ranking_perron);

%% MÉTODO 2: PAGERANK (CON FACTOR DE AMORTIGUAMIENTO)
alpha = 0.85; % Factor estándar utilizado por Google
% Se utiliza el método de la potencia para evitar crear una matriz densa.
% De esta forma ahorramos memoria al trabajar con matrices grandes (sparse).
r = ones(N, 1) / N;
for i = 1:100
    % El modelo combina la red real con un salto aleatorio uniforme
    r_nuevo = alpha * (P * r) + (1 - alpha) * (ones(N,1) / N);
    r_nuevo = r_nuevo / sum(r_nuevo); 
    
    % Comprobamos si el ranking se ha estabilizado
    if norm(r_nuevo - r, 1) < 1e-6
        fprintf('Convergencia de PageRank alcanzada en la iteración %d.\n', i);
        break; 
    end
    r = r_nuevo;
end
ranking_pagerank = r;

%% MÉTODO 3: MODELO DE KEENER
% Se añade una perturbación minúscula epsilon para asegurar que la matriz sea positiva.
% Esto permite que el algoritmo encuentre siempre una solución única y estable.
epsilon = 1/N;
% Aplicamos el cálculo del autovector sobre la matriz modificada
[V_k, D_k] = eigs(A + epsilon, 1); 
ranking_keener = abs(V_k);
ranking_keener = ranking_keener / sum(ranking_keener);

%% COMPARATIVA DE RESULTADOS (TOP 10)
[~, pos_pr] = sort(ranking_pagerank, 'descend');
nombres_jugadores = jugadores_unicos; 

fprintf('\n--- CLASIFICACIÓN FINAL PAGERANK (2000-2024) ---\n');
for r = 1:10
    idx_p = pos_pr(r);
    fprintf('%d. %-20s (Score: %.4f)\n', r, nombres_jugadores(idx_p), ranking_pagerank(idx_p));
end

%% TABLA COMPARATIVA DE LOS 5 MEJORES
[~, pos_pe] = sort(ranking_perron, 'descend');
[~, pos_ke] = sort(ranking_keener, 'descend');

fprintf('\n--- COMPARATIVA DE LOS TRES MÉTODOS (TOP 5) ---\n');
fprintf('%-5s | %-18s | %-18s | %-18s\n', 'Pos', 'Perron (Puro)', 'PageRank (0.85)', 'Keener');
fprintf('--------------------------------------------------------------------------\n');
for r = 1:5
    fprintf('%-5d | %-18s | %-18s | %-18s\n', r, ...
        nombres_jugadores(pos_pe(r)), ...
        nombres_jugadores(pos_pr(r)), ...
        nombres_jugadores(pos_ke(r)));
end