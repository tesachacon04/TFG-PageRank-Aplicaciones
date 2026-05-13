%% 1. EXTRACCIÓN DE DATOS (IDENTIFICANDO LOS NODOS)
% Leemos todos los archivos CSV históricos de la ATP.
archivos = dir('atp_matches_*.csv');
numero_archivos = length(archivos);
todos_los_jugadores = string([]); 
for k = 1:numero_archivos
    opts = detectImportOptions(archivos(k).name);
    opts.SelectedVariableNames = {'winner_name', 'loser_name'};
    tabla_nombres = readtable(archivos(k).name, opts);
    
    % Vamos guardando a todos los ganadores y perdedores
    todos_los_jugadores = [todos_los_jugadores; string(tabla_nombres.winner_name); string(tabla_nombres.loser_name)];
end

%% 2. CREACIÓN DEL DICCIONARIO (ASIGNANDO UN NÚMERO A CADA NOMBRE)
% Quitamos nombres repetidos y celdas vacías para tener la lista oficial
jugadores_unicos = unique(todos_los_jugadores);
jugadores_unicos(ismissing(jugadores_unicos) | jugadores_unicos == "") = [];
N = length(jugadores_unicos);
% A cada jugador le asignamos un índice (1, 2, 3...) para ubicarlo en la matriz.
diccionario = dictionary(jugadores_unicos, (1:N)');
fprintf('Red establecida con N = %d jugadores.\n', N);

%% 3. CONSTRUCCIÓN DE LA MATRIZ PONDERADA (DIFERENCIA DE PUNTOS)
% Usamos una matriz con muchos ceros (sparse) para ahorrar memoria
A = sparse(N, N); 
for k = 1:numero_archivos
    opts = detectImportOptions(archivos(k).name);
    % Nos quedamos solo con las columnas que nos dicen los puntos
    col_puntos = {'winner_name', 'loser_name', 'w_1stWon', 'w_2ndWon', 'l_svpt', 'l_1stWon', 'l_2ndWon', 'w_svpt'};
    opts.SelectedVariableNames = intersect(col_puntos, opts.VariableNames, 'stable');
    
    tabla_partidos = readtable(archivos(k).name, opts);
    tiene_puntos = all(ismember({'w_1stWon', 'l_1stWon'}, tabla_partidos.Properties.VariableNames));
    
    for i = 1:height(tabla_partidos)
        ganador = string(tabla_partidos.winner_name(i));
        perdedor = string(tabla_partidos.loser_name(i));
        
        if ~ismissing(ganador) && ~ismissing(perdedor) && ganador ~= "" && perdedor ~= ""
            idx_W = diccionario(ganador);
            idx_L = diccionario(perdedor);
            
            % Por defecto, la victoria vale 1
            peso = 1; 
            if tiene_puntos
                try
                    puntos_W = tabla_partidos.w_1stWon(i) + tabla_partidos.w_2ndWon(i) + ...
                               (tabla_partidos.l_svpt(i) - tabla_partidos.l_1stWon(i) - tabla_partidos.l_2ndWon(i));
                    puntos_L = tabla_partidos.l_1stWon(i) + tabla_partidos.l_2ndWon(i) + ...
                               (tabla_partidos.w_svpt(i) - tabla_partidos.w_1stWon(i) - tabla_partidos.w_2ndWon(i));
                    
                    diff = puntos_W - puntos_L;
                    if diff > 0
                        peso = diff; % El peso pasa a ser la diferencia exacta
                    end 
                catch
                    peso = 1; % Si hay algún error, volvemos a la victoria simple
                end
            end
            
            % Añadimos el peso a la matriz
            A(idx_W, idx_L) = A(idx_W, idx_L) + peso;
        end
    end
end

%% 4. CÁLCULO DEL RANKING (PAGERANK) 
% Definición de constantes del modelo
alpha = 0.85;       % Factor de amortiguamiento (Damping Factor)
max_iter = 100;     % Límite de iteraciones para la convergencia
tolerancia = 1e-6;  % Umbral de error residual

% Normalización por columnas: Construcción de la matriz de transición estocástica P
sum_columnas = full(sum(A, 1));
sum_columnas(sum_columnas == 0) = 1; % Evita divisiones por cero en nodos sin salida
P = A ./ sum_columnas;

% Inicialización del vector de ranking r (distribución uniforme inicial)
ranking_pagerank = ones(N, 1) / N;
e = ones(N, 1);

fprintf('Calculando PageRank mediante el método de la potencia...\n');
for i = 1:max_iter
    reparto_invictos = sum(ranking_pagerank) - sum(P * ranking_pagerank);
    
    % Aplicación de la ecuación de PageRank: Estructura real + Salto aleatorio
    r_nuevo = alpha * (P * ranking_pagerank + reparto_invictos * (e/N)) + (1 - alpha) * (e / N);
    
    % Verificación de la convergencia (Estacionariedad)
    if norm(r_nuevo - ranking_pagerank, 1) < tolerancia
        fprintf('Estacionariedad alcanzada en la iteración %d.\n', i);
        break;
    end
    ranking_pagerank = r_nuevo;
end

%% 5. RESULTADOS DEL MODELO ROBUSTO
% Vemos quiénes son los 5 mejores cuando la red funciona correctamente
[~, pos] = sort(ranking_pagerank, 'descend');
fprintf('\n--- TOP 5 PAGERANK (Modelo Estable) ---\n');
for i = 1:5
    fprintf('%d. %-20s (Score: %.4f)\n', i, jugadores_unicos(pos(i)), ranking_pagerank(pos(i)));
end

%% 6. EXPERIMENTO: ¿QUÉ PASA SI LOS INVICTOS ABSORBEN TODO? (El colapso)
fprintf('\n--- ANÁLISIS DE VULNERABILIDAD (Estados Absorbentes) ---\n');
% 1. Buscamos a los jugadores que nunca han perdido (su columna suma 0)
sum_columnas_A = full(sum(A, 1));
nodos_colgantes = find(sum_columnas_A == 0);
fprintf('Detección de %d jugadores invictos en la red histórica.\n', length(nodos_colgantes));

% 2. Les ponemos un "1" en la diagonal para que se queden con el prestigio y no lo suelten
P_exp = A;
for j = 1:length(nodos_colgantes)
    idx = nodos_colgantes(j);
    P_exp(idx, idx) = 1; % Esto convierte al jugador en un "agujero negro" de puntos
end

% 3. Calculo del ranking SIN factor de amortiguamiento (alpha = 1)
sum_columnas_exp = full(sum(P_exp, 1));
sum_columnas_exp(sum_columnas_exp == 0) = 1;
P_exp = P_exp ./ sum_columnas_exp;
r_exp = ones(N, 1) / N;

for iter = 1:500
    r_nuevo_exp = P_exp * r_exp; % Método de potencia puro, sin salto aleatorio
    if norm(r_nuevo_exp - r_exp, 1) < 1e-6
        fprintf('Estacionariedad del experimento alcanzada en la iteración %d.\n', iter);
        break; 
    end
    r_exp = r_nuevo_exp;
end

%% 7. RESULTADOS DEL EXPERIMENTO
% Al imprimir esto, verás cómo los desconocidos invictos "roban" el Top 5 a las estrellas
[~, pos_exp] = sort(r_exp, 'descend');
fprintf('\n--- TOP 5 EXPERIMENTO (Ranking absorbido por invictos) ---\n');
for i = 1:5
    fprintf('%d. %-20s (Score: %.4f)\n', i, jugadores_unicos(pos_exp(i)), r_exp(pos_exp(i)));
end