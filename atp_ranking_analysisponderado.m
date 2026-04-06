%% 1. CONFIGURACIÓN Y LECTURA
archivos = dir('atp_matches_*.csv');
numero_archivos = length(archivos);
fprintf('¡Genial! He encontrado %d archivos CSV.\n', numero_archivos);

todos_los_jugadores = string([]); % Forzamos que sea un vector de texto vacío

for k = 1:numero_archivos
    nombre_archivo = archivos(k).name;
    fprintf('Analizando nombres en: %s...\n', nombre_archivo);
    
    opts = detectImportOptions(nombre_archivo);
    opts.SelectedVariableNames = {'winner_name', 'loser_name'};
    tabla_nombres = readtable(nombre_archivo, opts);
    
    % Convertimos a string y quitamos posibles valores nulos (missing)
    ganadores = string(tabla_nombres.winner_name);
    perdedores = string(tabla_nombres.loser_name);
    
    todos_los_jugadores = [todos_los_jugadores; ganadores; perdedores];
end

%% 2. CREACIÓN DEL DICCIONARIO (Limpieza profunda)
% Quitamos los "missing", los espacios vacíos ("") y luego sacamos los únicos
jugadores_unicos = unique(todos_los_jugadores);
jugadores_unicos(ismissing(jugadores_unicos)) = []; % Borra nulos
jugadores_unicos(jugadores_unicos == "") = [];      % Borra vacíos

N = length(jugadores_unicos);
indices = (1:N)'; % Creamos los números del 1 al N


diccionario = dictionary(jugadores_unicos, indices);

fprintf('\n------------------------------------------\n');
fprintf('ÉXITO: Tenemos %d jugadores únicos.\n', N);
fprintf('Creando matriz de %d x %d...\n', N, N);


%% 3. CONSTRUCCIÓN DE LA MATRIZ PONDERADA (Optimizado)
A = sparse(N, N); 
for k = 1:numero_archivos
    nombre_archivo = archivos(k).name;
    opts = detectImportOptions(nombre_archivo);
    
    % Leemos solo lo imprescindible para no saturar la memoria
    columnas_deseadas = {'winner_name', 'loser_name', 'w_1stWon', 'w_2ndWon', 'l_svpt', 'l_1stWon', 'l_2ndWon', 'w_svpt'};
    % Verificamos qué columnas existen realmente en este archivo concreto
    columnas_presentes = intersect(columnas_deseadas, opts.VariableNames, 'stable');
    opts.SelectedVariableNames = columnas_presentes;
    
    tabla_partidos = readtable(nombre_archivo, opts);
    
    % Convertimos a matriz numérica para que sea veloz
    % Si faltan columnas de puntos, usamos peso 1
    tiene_puntos = all(ismember({'w_1stWon', 'l_1stWon'}, tabla_partidos.Properties.VariableNames));

    for i = 1:height(tabla_partidos)
        ganador = string(tabla_partidos.winner_name(i));
        perdedor = string(tabla_partidos.loser_name(i));
        
        if ~ismissing(ganador) && ~ismissing(perdedor) && ganador ~= "" && perdedor ~= ""
            idx_W = diccionario(ganador);
            idx_L = diccionario(perdedor);
            
            peso = 1; % Peso por defecto
            if tiene_puntos
                try
                    % Cálculo de la "paliza": puntos ganados vs puntos perdidos
                    puntos_W = tabla_partidos.w_1stWon(i) + tabla_partidos.w_2ndWon(i) + ...
                               (tabla_partidos.l_svpt(i) - tabla_partidos.l_1stWon(i) - tabla_partidos.l_2ndWon(i));
                    puntos_L = tabla_partidos.l_1stWon(i) + tabla_partidos.l_2ndWon(i) + ...
                               (tabla_partidos.w_svpt(i) - tabla_partidos.w_1stWon(i) - tabla_partidos.w_2ndWon(i));
                    
                    diff = puntos_W - puntos_L;
                    if diff > 0, peso = diff; end
                catch
                    peso = 1;
                end
            end
            % Sumamos el peso al arco (Perdedor -> Ganador)
            A(idx_W, idx_L) = A(idx_W, idx_L) + peso;
        end
    end
end

%% 4. CÁLCULO DE PAGERANK (Con corrección de invictos)
alpha = 0.85;
max_iter = 100;
tolerancia = 1e-6;

% Normalización estocástica
d = full(sum(A, 1));
d(d == 0) = 1; 
P = A * sparse(1:N, 1:N, 1./d);

r = ones(N, 1) / N;
v = ones(N, 1) / N;

fprintf('\nCalculando PageRank Ponderado...\n');
for i = 1:max_iter
    % Corrección para que la suma siempre sea 1 (Matemática pura)
    r_nuevo = alpha * (P * r) + (1 - alpha) * v;
    r_nuevo = r_nuevo / sum(r_nuevo); % Aseguramos estocasticidad
    
    if norm(r_nuevo - r, 1) < tolerancia
        fprintf('Convergencia en iteración %d.\n', i);
        break;
    end
    r = r_nuevo;
end
ranking_pagerank = r;

%% 5. MOSTRAR RESULTADOS
[~, pos] = sort(ranking_pagerank, 'descend');
fprintf('\n--- TOP 5 PAGERANK (Método Iterativo) ---\n');
for i = 1:5
    fprintf('%d. %-20s (Score: %.4f)\n', i, jugadores_unicos(pos(i)), ranking_pagerank(pos(i)));
end