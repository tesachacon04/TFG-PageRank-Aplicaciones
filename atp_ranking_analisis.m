
%% 1. EXTRACCIÓN Y PREPROCESAMIENTO DE DATOS
% Se cargan los registros históricos de la ATP para definir el universo de nodos (jugadores)
archivos = dir('atp_matches_*.csv');
numero_archivos = length(archivos);
todos_los_jugadores = string([]); 

for k = 1:numero_archivos
    nombre_archivo = archivos(k).name;
    opts = detectImportOptions(nombre_archivo);
    opts.SelectedVariableNames = {'winner_name', 'loser_name'};
    tabla_nombres = readtable(nombre_archivo, opts);
    
    % Recopilación de todos los vértices que componen la red
    todos_los_jugadores = [todos_los_jugadores; string(tabla_nombres.winner_name); string(tabla_nombres.loser_name)];
end

%% 2. CONSTRUCCIÓN DEL DICCIONARIO TOPOLÓGICO
% Normalización: Eliminación de valores nulos y filtrado de nombres únicos
jugadores_unicos = unique(todos_los_jugadores);
jugadores_unicos(ismissing(jugadores_unicos) | jugadores_unicos == "") = [];
N = length(jugadores_unicos);

% Mapeo de nombres a índices matriciales para facilitar el acceso computacional
diccionario = dictionary(jugadores_unicos, (1:N)');
fprintf('Red establecida con N = %d jugadores.\n', N);

%% 3. GENERACIÓN DE LA MATRIZ DE ADYACENCIA DISPERSA
% Se utiliza representación 'sparse' para optimizar el uso de memoria RAM
A = sparse(N, N); 
for k = 1:numero_archivos
    tabla_partidos = readtable(archivos(k).name, opts);
    for i = 1:height(tabla_partidos)
        ganador = string(tabla_partidos.winner_name(i));
        perdedor = string(tabla_partidos.loser_name(i));
        
        if ~ismissing(ganador) && ~ismissing(perdedor) && ganador ~= "" && perdedor ~= ""
            % La arista dirigida refleja la transferencia de prestigio (Derrotado -> Ganador)
            idx_g = diccionario(ganador);
            idx_p = diccionario(perdedor);
            A(idx_g, idx_p) = A(idx_g, idx_p) + 1;
        end
    end
end

%% 4. ALGORITMO PAGERANK (MÉTODO DE LA POTENCIA)
% Definición de constantes del modelo
alpha = 0.85;       % Factor de amortiguamiento (Damping Factor)
max_iter = 100;     % Límite de iteraciones para la convergencia
tolerancia = 1e-6;  % Umbral de error residual

% Normalización por columnas: Construcción de la matriz de transición estocástica P
sum_columnas = full(sum(A, 1));
sum_columnas(sum_columnas == 0) = 1; % Evita divisiones por cero en nodos sin salida
P = A ./ sum_columnas;

% Inicialización del vector de ranking r (distribución uniforme inicial)
r = ones(N, 1) / N;
e = ones(N, 1);

fprintf('Iniciando proceso iterativo de convergencia...\n');
for i = 1:max_iter
    % Manejo de nodos colgantes para evitar la fuga de prestigio en el sistema
    reparto_invictos = sum(r) - sum(P * r); 
    
    % Aplicación de la ecuación de PageRank: Estructura real + Salto aleatorio
    r_nuevo = alpha * (P * r + reparto_invictos * (e/N)) + (1 - alpha) * (e / N);
    
    % Verificación de la convergencia (Estacionariedad)
    if norm(r_nuevo - r, 1) < tolerancia
        fprintf('Estacionariedad alcanzada en la iteración %d.\n', i);
        break;
    end
    r = r_nuevo;
end

%% 5. RESULTADOS FINALES
[~, pos] = sort(r, 'descend');
fprintf('\n--- TOP 10 ATP (Importancia Estructural) ---\n');
for i = 1:10
    fprintf('%d. %-20s | Score: %.5f\n', i, jugadores_unicos(pos(i)), r(pos(i))); 
end