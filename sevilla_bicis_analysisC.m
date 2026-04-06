% =========================================================================
% TFG: ANÁLISIS DE LA RED DE CARRILES BICI MEDIANTE PAGERANK
% =========================================================================

N = size(LLAM,1); 
suma_columnas = sum(LLAM, 1);
MM = zeros(N, N);
for i = 1:N
    if suma_columnas(i) ~= 0
        MM(:, i) = LLAM(:, i) / suma_columnas(i);
    else
        MM(:, i) = 1 / N; 
    end
end

% 3. PARÁMETRO DE AMORTIGUAMIENTO (Damping Factor)
alpha = 0.85; % El 85% de las veces el ciclista sigue la red conectada

% =========================================================================
% MODELO 1: PAGERANK CLÁSICO 
% =========================================================================
v1 = ones(N, 1) / N; % Vector de teletransportación uniforme

% Construimos la Matriz de Google (G) para el Modelo 1
G1 = alpha * MM + (1 - alpha) * (v1 * ones(1, N));

% Cálculo mediante iteraciones matemáticas
x1 = ones(N, 1) / N; % Puntuación inicial
for iter = 1:100
    x1 = G1 * x1;
end

% =========================================================================
% MODELO 2: PAGERANK PERSONALIZADO
% =========================================================================
calles_sevici = [1,3,4,6,7,9,11,12,13,15,17,20,22]; 

v2 = zeros(N, 1);
v2(calles_sevici) = 1; 
v2 = v2 / sum(v2); % Normalizamos matemáticamente

% Construimos la Matriz de Google (G) para el Modelo 2
G2 = alpha * MM + (1 - alpha) * (v2 * ones(1, N));

% Cálculo mediante iteraciones matemáticas
x2 = ones(N, 1) / N; % Puntuación inicial
for iter = 1:100
    x2 = G2 * x2;
end

% =========================================================================
% RESULTADOS Y GRÁFICAS
% =========================================================================
% Muestra los resultados numéricos en la consola
disp('--- RESULTADOS MODELO 1 (Red Clásica) ---');
disp(x1);

disp('--- RESULTADOS MODELO 2 (Red con SEVici) ---');
disp(x2);

% Crea una gráfica visual comparativa
figure;
plot(1:N, x1, '-o', 'Color', [0 0.4470 0.7410], 'LineWidth', 2, 'MarkerFaceColor', [0 0.4470 0.7410]); hold on;
plot(1:N, x2, '-s', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
title('Impacto de las Estaciones Principales de SEVici en la Red Ciclista');
xlabel('Nº de Calle');
ylabel('Nivel de Importancia (PageRank)');
legend('Modelo 1: Flujo Normal', 'Modelo 2: Flujo Intermodal (SEVici)');
grid on;