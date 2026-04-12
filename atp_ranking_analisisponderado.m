%% 1. RECOGER LOS DATOS
archivos = dir('atp_matches_*.csv');
numero_archivos = length(archivos);
todos_los_jugadores = string([]); 

for k = 1:numero_archivos
    opts = detectImportOptions(archivos(k).name);
    opts.SelectedVariableNames = {'winner_name', 'loser_name'};
    tabla_nombres = readtable(archivos(k).name, opts);
    
    % Recopilamos todos los nombres de los archivos para identificar a los jugadores
    todos_los_jugadores = [todos_los_jugadores; string(tabla_nombres.winner_name); string(tabla_nombres.loser_name)];
end

%% 2. LIMPIEZA Y DICCIONARIO
% Eliminamos repetidos y valores nulos para obtener la lista única de tenistas
jugadores_unicos = unique(todos_los_jugadores);
jugadores_unicos(ismissing(jugadores_unicos) | jugadores_unicos == "") = [];
N = length(jugadores_unicos);

% Asignamos un índice numérico a cada jugador para organizar la matriz
diccionario = dictionary(jugadores_unicos, (1:N)');
fprintf('Base de datos establecida con %d jugadores únicos.\n', N);

%% 3. CONSTRUCCIÓN DE LA MATRIZ PONDERADA
% Se utiliza una matriz dispersa (sparse) para optimizar el uso de memoria
A = sparse(N, N); 
for k = 1:numero_archivos
    opts = detectImportOptions(archivos(k).name);
    % Seleccionamos las columnas de puntos para calcular la diferencia en cada partido
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
            
            % Si no hay datos detallados el peso es 1. Si los hay, se calcula el diferencial.
            peso = 1; 
            if tiene_puntos
                try
                    % Cálculo de puntos totales: ganados por el vencedor vs ganados por el perdedor
                    puntos_W = tabla_partidos.w_1stWon(i) + tabla_partidos.w_2ndWon(i) + ...
                               (tabla_partidos.l_svpt(i) - tabla_partidos.l_1stWon(i) - tabla_partidos.l_2ndWon(i));
                    puntos_L = tabla_partidos.l_1stWon(i) + tabla_partidos.l_2ndWon(i) + ...
                               (tabla_partidos.w_svpt(i) - tabla_partidos.w_1stWon(i) - tabla_partidos.w_2ndWon(i));
                    
                    diff = puntos_W - puntos_L;
                    if diff > 0, peso = diff; end % A mayor diferencia de puntos, mayor peso en la red
                catch
                    peso = 1;
                end
            end
            % Se suma el valor de la victoria a la relación entre perdedor y ganador
            A(idx_W, idx_L) = A(idx_W, idx_L) + peso;
        end
    end
end

%% 4. CÁLCULO DEL RANKING (PAGERANK)
alpha = 0.85;       % Factor de amortiguamiento
max_iter = 100;     
tolerancia = 1e-6;  

% Normalización de la matriz para que las columnas sumen 1
d = full(sum(A, 1));
d(d == 0) = 1; 
P = A * sparse(1:N, 1:N, 1./d);

r = ones(N, 1) / N; % Distribución inicial uniforme
v = ones(N, 1) / N;

fprintf('Calculando convergencia del ranking...\n');
for i = 1:max_iter
    % Aplicación del algoritmo PageRank
    r_nuevo = alpha * (P * r) + (1 - alpha) * v;
    r_nuevo = r_nuevo / sum(r_nuevo); % Re-normalización para asegurar estocasticidad
    
    % Comprobación de parada por convergencia
    if norm(r_nuevo - r, 1) < tolerancia
        fprintf('Convergencia finalizada en la iteración %d.\n', i);
        break;
    end
    r = r_nuevo;
end

%% 5. RESULTADOS
[~, pos] = sort(r, 'descend');
fprintf('\n--- TOP 10 TENISTAS (Ranking Ponderado) ---\n');
for i = 1:10
    fprintf('%d. %-20s (Score: %.5f)\n', i, jugadores_unicos(pos(i)), r(pos(i)));
end