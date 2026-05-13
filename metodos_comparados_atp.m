%%% =========================================================================
%%% SCRIPT: metodos_comparados_atp.m
%%% DESCRIPCIÓN: Comparación de tres modelos de centralidad (Perron, PageRank
%%% y Keener) aplicados a la red histórica de victorias de la ATP.
%%% =========================================================================
%% EJECUTAR DESPUÉS DE **`atp_ranking_analisis.m`**
%% 1. PREPARACIÓN DE LA MATRIZ DE TRANSICIÓN
% Normalizamos la matriz de adyacencia (A) para que las columnas sumen 1.
% Así convertimos las victorias en probabilidades de flujo (P).
%HAY QUE EJECUTARLO DESPUES DEL ARCHIVO atp_ranking_analisis.m
sum_columnas = sum(A, 1);
sum_columnas(sum_columnas == 0) = 1; % Evitamos dividir por cero en nodos sin salidas
P = A ./ sum_columnas;
N = size(P, 1);

%% MÉTODO 1: PERRON-FROBENIUS (EL MODELO PURO)
% Calculamos el autovector asociado al autovalor de mayor módulo.
% Usamos 'eigs' porque es muy eficiente para matrices dispersas (con muchos ceros).
% Este modelo refleja el prestigio puro, sin añadir saltos aleatorios.
[V, D] = eigs(P, 1); 
ranking_perron = abs(V);
ranking_perron = ranking_perron / sum(ranking_perron);

%% MÉTODO 2: PAGERANK DE GOOGLE (ITERATIVO)
alpha = 0.85; % Factor de amortiguamiento estándar (85% flujo real, 15% aleatorio)
ranking_pagerank = ones(N, 1) / N; % Vector inicial donde todos los tenistas tienen la misma importancia
e = ones(N, 1);

fprintf('Calculando PageRank mediante el método de la potencia...\n');
for i = 1:max_iter
    % CORRECCION DE NODOS COLGANTES (Dangling Nodes):
    % Se calcula la pérdida de masa de probabilidad debida a jugadores invictos (nunca han perdido un partido) 
    % (columnas de ceros en P) para redistribuirla y mantener la estocasticidad.
    reparto_invictos = sum(ranking_pagerank) - sum(P * ranking_pagerank); %calcula cuánta importancia se ha perdido en esa iteración debido a los jugadores que no tienen derrotas
    
    % Aplicación de la ecuación de PageRank: Estructura real + Salto aleatorio
    r_nuevo = alpha * (P * ranking_pagerank + reparto_invictos * (e/N)) + (1 - alpha) * (e / N);
    
    % Verificación de la convergencia (Estacionariedad)
    if norm(r_nuevo - ranking_pagerank, 1) < tolerancia
        fprintf('Estacionariedad alcanzada en la iteración %d.\n', i);
        break;
    end
    ranking_pagerank = r_nuevo;
end
%% MÉTODO 3: VERSIÓN REGULARIZADA DE KEENER
% Aplicamos una perturbación minúscula (epsilon) directamente sobre la matriz de 
% adyacencia original. Esto asegura que la matriz sea estrictamente positiva,
% garantizando conectividad total sin alterar el peso real de los partidos.
epsilon = 1/N;
[V_k, D_k] = eigs(A + sparse(1:N, 1:N, epsilon), 1);
ranking_keener = abs(V_k);
ranking_keener = ranking_keener / sum(ranking_keener);

%% COMPARATIVA DE RESULTADOS Y EXTRACCIÓN DE TABLAS
% Ordenamos de mayor a menor puntuación para sacar el Top 10 de PageRank
[~, pos_pr] = sort(ranking_pagerank, 'descend');
nombres_jugadores = jugadores_unicos; 

fprintf('\n--- CLASIFICACIÓN FINAL PAGERANK (2000-2024) ---\n');
for r = 1:10
    idx_p = pos_pr(r);
    fprintf('%d. %-20s (Score: %.4f)\n', r, nombres_jugadores(idx_p), ranking_pagerank(idx_p));
end

%% TABLA COMPARATIVA DE LOS 3 MÉTODOS (TOP 5)
% Ordenamos también los resultados de Perron y Keener para poder compararlos
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