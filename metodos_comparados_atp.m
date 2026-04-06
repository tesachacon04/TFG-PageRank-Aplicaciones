%% FASE 3: COMPETICIÓN DE MÉTODOS
% 1. PREPARACIÓN
sum_columnas = sum(A, 1);
sum_columnas(sum_columnas == 0) = 1; 
P = A ./ sum_columnas;
N = size(P, 1);

%% MÉTODO 1: PERRON-FROBENIUS
[V, D] = eigs(P, 1); 
ranking_perron = abs(V);
ranking_perron = ranking_perron / sum(ranking_perron);

%% MÉTODO 2: PAGERANK 
alpha = 0.85;
% IMPORTANTE: No creamos la matriz G entera (G = alpha*P + (1-alpha)*1/N*E)
% porque E es una matriz llena y nos cargamos el ahorro de memoria de sparse.
% Usamos el Método de la Potencia (el bucle que vimos antes) que es lo ideal.

r = ones(N, 1) / N;
for i = 1:100
    r_nuevo = alpha * (P * r) + (1 - alpha) * (ones(N,1) / N);
    r_nuevo = r_nuevo / sum(r_nuevo); 
    if norm(r_nuevo - r, 1) < 1e-6, break; end
    r = r_nuevo;
end
ranking_pagerank = r;

%% MÉTODO 3: KEENER
epsilon = 1/N;
% Creamos una matriz donde sumamos un poquito a cada entrada para que sea positiva
% pero de forma eficiente para matrices sparse:
[V_k, D_k] = eigs(A + epsilon, 1); 

ranking_keener = abs(V_k);
ranking_keener = ranking_keener / sum(ranking_keener);

%% COMPARATIVA DE RESULTADOS (TOP 10)
[~, pos_pr] = sort(ranking_pagerank, 'descend');
nombres_jugadores = jugadores_unicos; 

fprintf('\n--- TOP 10 RANKING PAGERANK (2000-2024) ---\n');
for r = 1:10
    idx_p = pos_pr(r);
    fprintf('%d. %-20s (Score: %.4f)\n', r, nombres_jugadores(idx_p), ranking_pagerank(idx_p));
end

%% Tabla comparativa para los 5 mejores
[~, pos_pe] = sort(ranking_perron, 'descend');
[~, pos_ke] = sort(ranking_keener, 'descend');

fprintf('\n--- COMPARATIVA DE MÉTODOS (TOP 5) ---\n');
fprintf('%-5s | %-18s | %-18s | %-18s\n', 'Pos', 'Perron (Puro)', 'PageRank (alpha)', 'Keener');
fprintf('--------------------------------------------------------------------------\n');
for r = 1:5
    fprintf('%-5d | %-18s | %-18s | %-18s\n', r, ...
        nombres_jugadores(pos_pe(r)), ...
        nombres_jugadores(pos_pr(r)), ...
        nombres_jugadores(pos_ke(r)));
end