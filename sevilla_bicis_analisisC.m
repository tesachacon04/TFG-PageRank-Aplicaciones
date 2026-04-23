% =========================================================================
% TFG: ANÁLISIS DE LA RED DE CARRILES BICI (GRAFO DUAL - CARRILES)
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
alpha = 0.85; 
I = eye(N); % Matriz identidad necesaria para el sistema lineal

% --- MODELO 1: PAGERANK CLÁSICO (Carriles) ---
v1 = ones(N, 1) / N; 
% Resolución matricial directa (Sistema Lineal)
x1 = (I - alpha * MM) \ ((1 - alpha) * v1);
x1 = x1 / sum(x1); % Normalización por seguridad

% --- MODELO 2: PAGERANK PERSONALIZADO (Carriles con SEVici) ---
calles_sevici = [1,3,4,6,7,9,11,12,13,15,17,20,22]; 
v2 = zeros(N, 1);
v2(calles_sevici) = 1; 
v2 = v2 / sum(v2); 
% Resolución matricial directa (Sistema Lineal)
x2 = (I - alpha * MM) \ ((1 - alpha) * v2);
x2 = x2 / sum(x2); % Normalización por seguridad

% --- MOSTRAR RESULTADOS ---
fprintf('\n--- RESULTADOS MODELO 1 (Red Clásica - Carriles) ---\n');
disp(x1);
fprintf('\n--- RESULTADOS MODELO 2 (Red con SEVici - Carriles) ---\n');
disp(x2);

% --- GRÁFICA COMPARATIVA ---
figure;
plot(1:N, x1, '-o', 'Color', [0 0.4470 0.7410], 'LineWidth', 2, 'MarkerFaceColor', [0 0.4470 0.7410]); 
hold on;
plot(1:N, x2, '-s', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
title('Impacto de las Estaciones Principales de SEVici en los carriles');
xlabel('Nº de Carril (Grafo Dual)');
ylabel('Nivel de Importancia (PageRank)');
legend('Modelo 1: Flujo Normal', 'Modelo 2: Flujo Intermodal (SEVici)');
grid on;