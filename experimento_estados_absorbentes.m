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


%% 3. CONSTRUCCIÓN DE LA MATRIZ PONDERADA (Por diferencia de puntos)
A = sparse(N, N); 

for k = 1:numero_archivos
    nombre_archivo = archivos(k).name;
    opts = detectImportOptions(nombre_archivo);
    
    % --> AÑADIMOS LAS COLUMNAS DE ESTADÍSTICAS A LA LECTURA
    % w_svpt = puntos de saque del ganador, l_svpt = puntos de saque del perdedor, etc.
    opts.SelectedVariableNames = {'winner_name', 'loser_name', 'w_svpt', 'w_1stWon', 'w_2ndWon', 'l_svpt', 'l_1stWon', 'l_2ndWon'};
    tabla_partidos = readtable(nombre_archivo, opts);
    
    for i = 1:height(tabla_partidos)
        ganador = string(tabla_partidos.winner_name(i));
        perdedor = string(tabla_partidos.loser_name(i));
        
        if ~ismissing(ganador) && ~ismissing(perdedor) && ganador ~= "" && perdedor ~= ""
            idx_ganador = diccionario(ganador);
            idx_perdedor = diccionario(perdedor);
            
            % --> CALCULAMOS EL "PESO"
            % Matemáticas puras: Puntos ganados al saque + Puntos ganados al resto
            try
                puntos_ganador = tabla_partidos.w_1stWon(i) + tabla_partidos.w_2ndWon(i) + (tabla_partidos.l_svpt(i) - tabla_partidos.l_1stWon(i) - tabla_partidos.l_2ndWon(i));
                puntos_perdedor = tabla_partidos.l_1stWon(i) + tabla_partidos.l_2ndWon(i) + (tabla_partidos.w_svpt(i) - tabla_partidos.w_1stWon(i) - tabla_partidos.w_2ndWon(i));
                
                peso = puntos_ganador - puntos_perdedor;
                
                % Si faltan datos en el CSV (ej. retiradas, partidos muy antiguos), ponemos peso 1 por defecto
                if isnan(peso) || peso <= 0
                    peso = 1; 
                end
            catch
                peso = 1; % Si hay algún error leyendo la columna, peso estándar
            end
            
            % --> SUMAMOS EL PESO EN LUGAR DE UN 1
            A(idx_ganador, idx_perdedor) = A(idx_ganador, idx_perdedor) + peso;
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
    r_nuevo = alpha * (P * r) + (1 - alpha) * (e / N);
    
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
%% 6. EXPERIMENTO: EL PELIGRO DE LOS NODOS SUMIDEROS (Cap. 6)
fprintf('\n--- EXPERIMENTO: ESTADOS ABSORBENTES (1 en la diagonal) ---\n');

% 1. Localizar Nodos Sumideros (Jugadores que nunca han perdido) en la matriz A
sum_columnas_A = full(sum(A, 1));
nodos_sumideros = find(sum_columnas_A == 0);
fprintf('Se han detectado %d jugadores invictos (sumideros).\n', length(nodos_sumideros));

% 2. Construir la matriz de prueba (P_exp) con el MÉTOD0 2 DEL LIBRO
P_exp = A;
for j = 1:length(nodos_sumideros)
    idx = nodos_sumideros(j);
    P_exp(idx, idx) = 1; % El jugador invicto "se vota a sí mismo" (Diagonal)
end

% 3. Normalizamos P_exp por columnas
sum_columnas_exp = full(sum(P_exp, 1));
sum_columnas_exp(sum_columnas_exp == 0) = 1; % Por seguridad
P_exp = P_exp ./ sum_columnas_exp;

% 4. Calculamos el Método de la Potencia PURO
r_exp = ones(N, 1) / N;
for iter = 1:500
    r_nuevo_exp = P_exp * r_exp; % Multiplicación pura, sin teleportación
    if norm(r_nuevo_exp - r_exp, 1) < 1e-6
        fprintf('Convergencia del experimento alcanzada en iteración %d.\n', iter);
        break; 
    end
    r_exp = r_nuevo_exp;
end

% 5. Mostramos el "Desastre" Matemático
[~, pos_exp] = sort(r_exp, 'descend');
fprintf('\n--- TOP 5 EXPERIMENTO (Ranking Roto por Estados Absorbentes) ---\n');
for i = 1:5
    fprintf('%d. %-20s (Score: %.4f)\n', i, jugadores_unicos(pos_exp(i)), r_exp(pos_exp(i)));
end