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


%% 3. CONSTRUCCIÓN DE LA MATRIZ DISPERSA (Uso eficiente de memoria)
% En lugar de zeros(N,N), usamos sparse.
A = sparse(N, N); 

for k = 1:numero_archivos
    nombre_archivo = archivos(k).name;
    opts = detectImportOptions(nombre_archivo);
    opts.SelectedVariableNames = {'winner_name', 'loser_name'};
    tabla_partidos = readtable(nombre_archivo, opts);
    
    for i = 1:height(tabla_partidos)
        ganador = string(tabla_partidos.winner_name(i));
        perdedor = string(tabla_partidos.loser_name(i));
        
        if ~ismissing(ganador) && ~ismissing(perdedor) && ganador ~= "" && perdedor ~= ""
            idx_ganador = diccionario(ganador);
            idx_perdedor = diccionario(perdedor);
            % Rellenamos la matriz de adyacencia
            A(idx_ganador, idx_perdedor) = A(idx_ganador, idx_perdedor) + 1;
        end
    end
end

%% 4. CÁLCULO DE PAGERANK (MÉTODO DE LA POTENCIA)
% Definimos parámetros
alpha = 0.85;
max_iter = 100; % Cuántas veces repetimos el proceso
tolerancia = 1e-6; % Cuando el cambio sea menor que esto, paramos

% Normalizamos A para obtener la matriz de transición P
sum_columnas = full(sum(A, 1)); % sum de sparse a vector normal
sum_columnas(sum_columnas == 0) = 1; 
P = A ./ sum_columnas;

% Inicializamos el ranking (todos empiezan con el mismo peso)
r = ones(N, 1) / N;
e = ones(N, 1);

fprintf('\nCalculando PageRank mediante el Método de la Potencia...\n');

for i = 1:max_iter
    % Corregimos la pérdida de puntuación de los invictos
    reparto_invictos = sum(r) - sum(P * r); 
    r_nuevo = alpha * (P * r + reparto_invictos * (e/N)) + (1 - alpha) * (e / N);
    % Comprobamos si ya ha convergido (si los números han dejado de cambiar)
    if norm(r_nuevo - r, 1) < tolerancia
        fprintf('¡Convergencia alcanzada en la iteración %d!\n', i);
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