%% 1. CARGA DE DATOS HISTÓRICOS
archivos = dir('atp_matches_*.csv');
numero_archivos = length(archivos);
todos_los_jugadores = string([]); 

for k = 1:numero_archivos
    nombre_archivo = archivos(k).name;
    opts = detectImportOptions(nombre_archivo);
    opts.SelectedVariableNames = {'winner_name', 'loser_name'};
    tabla_nombres = readtable(nombre_archivo, opts);
    
    % Recopilación de vértices para el grafo global
    todos_los_jugadores = [todos_los_jugadores; string(tabla_nombres.winner_name); string(tabla_nombres.loser_name)];
end

%% 2. ESTRUCTURACIÓN DEL DICCIONARIO DE NODOS
% Limpieza de registros y definición de la lista única de jugadores
jugadores_unicos = unique(todos_los_jugadores);
jugadores_unicos(ismissing(jugadores_unicos) | jugadores_unicos == "") = [];
N = length(jugadores_unicos);

% Mapeo de nombres a índices para la construcción matricial
diccionario = dictionary(jugadores_unicos, (1:N)');
fprintf('Red establecida con %d nodos únicos.\n', N);

%% 3. CONSTRUCCIÓN DE LA MATRIZ PONDERADA (Diferencial de puntos)
A = sparse(N, N); 
for k = 1:numero_archivos
    opts = detectImportOptions(archivos(k).name);
    % Columnas necesarias para calcular la intensidad de la victoria
    opts.SelectedVariableNames = {'winner_name', 'loser_name', 'w_svpt', 'w_1stWon', 'w_2ndWon', 'l_svpt', 'l_1stWon', 'l_2ndWon'};
    tabla_partidos = readtable(archivos(k).name, opts);
    
    for i = 1:height(tabla_partidos)
        ganador = string(tabla_partidos.winner_name(i));
        perdedor = string(tabla_partidos.loser_name(i));
        
        if ~ismissing(ganador) && ~ismissing(perdedor) && ganador ~= "" && perdedor ~= ""
            idx_W = diccionario(ganador);
            idx_L = diccionario(perdedor);
            
            % Cálculo del diferencial de puntos ganados totales
            try
                puntos_W = tabla_partidos.w_1stWon(i) + tabla_partidos.w_2ndWon(i) + ...
                           (tabla_partidos.l_svpt(i) - tabla_partidos.l_1stWon(i) - tabla_partidos.l_2ndWon(i));
                puntos_L = tabla_partidos.l_1stWon(i) + tabla_partidos.l_2ndWon(i) + ...
                           (tabla_partidos.w_svpt(i) - tabla_partidos.w_1stWon(i) - tabla_partidos.w_2ndWon(i));
                
                peso = puntos_W - puntos_L;
                if isnan(peso) || peso <= 0, peso = 1; end
            catch
                peso = 1; % Valor por defecto ante ausencia de datos detallados
            end
            
            % La arista dirigida refleja la transferencia de valor según la contundencia
            A(idx_W, idx_L) = A(idx_W, idx_L) + peso;
        end
    end
end

%% 4. CÁLCULO DE PAGERANK ESTÁNDAR
alpha = 0.85;
max_iter = 100;
tolerancia = 1e-6;

% Normalización estocástica por columnas
sum_columnas = full(sum(A, 1));
sum_columnas(sum_columnas == 0) = 1; 
P = A ./ sum_columnas;

r = ones(N, 1) / N;
e = ones(N, 1);

fprintf('Calculando PageRank mediante el método de la potencia...\n');
for i = 1:max_iter
    r_nuevo = alpha * (P * r) + (1 - alpha) * (e / N);
    if norm(r_nuevo - r, 1) < tolerancia
        fprintf('Convergencia alcanzada en la iteración %d.\n', i);
        break;
    end
    r = r_nuevo;
end

%% 5. RESULTADOS DEL MODELO ROBUSTO
[~, pos] = sort(r, 'descend');
fprintf('\n--- TOP 5 PAGERANK (Modelo Estable) ---\n');
for i = 1:5
    fprintf('%d. %-20s (Score: %.4f)\n', i, jugadores_unicos(pos(i)), r(pos(i)));
end

%% 6. EXPERIMENTO: IMPACTO DE LOS ESTADOS ABSORBENTES (Nodos Sumideros)
fprintf('\n--- ANÁLISIS DE VULNERABILIDAD (Estados Absorbentes) ---\n');

% Localización de jugadores invictos (sumideros en el grafo)
sum_columnas_A = full(sum(A, 1));
nodos_sumideros = find(sum_columnas_A == 0);
fprintf('Detección de %d jugadores invictos en la red histórica.\n', length(nodos_sumideros));

% Construcción de la matriz con autobucle en nodos colgantes
P_exp = A;
for j = 1:length(nodos_sumideros)
    idx = nodos_sumideros(j);
    P_exp(idx, idx) = 1; % El nodo absorbe todo el flujo de entrada
end

% Normalización y cálculo del método de potencia puro (sin factor de amortiguamiento)
sum_columnas_exp = full(sum(P_exp, 1));
sum_columnas_exp(sum_columnas_exp == 0) = 1;
P_exp = P_exp ./ sum_columnas_exp;

r_exp = ones(N, 1) / N;
for iter = 1:500
    r_nuevo_exp = P_exp * r_exp; 
    if norm(r_nuevo_exp - r_exp, 1) < 1e-6
        fprintf('Estacionariedad del experimento alcanzada en la iteración %d.\n', iter);
        break; 
    end
    r_exp = r_nuevo_exp;
end

%% 7. VISUALIZACIÓN DEL COLAPSO DEL RANKING
[~, pos_exp] = sort(r_exp, 'descend');
fprintf('\n--- TOP 5 EXPERIMENTO (Ranking absorbido por invictos) ---\n');
for i = 1:5
    fprintf('%d. %-20s (Score: %.4f)\n', i, jugadores_unicos(pos_exp(i)), r_exp(pos_exp(i)));
end