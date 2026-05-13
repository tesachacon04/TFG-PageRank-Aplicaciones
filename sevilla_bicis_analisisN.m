% =========================================================================
% TFG: ANÁLISIS DE LA RED DE CARRILES BICI (GRAFO PRIMAL - NODOS)
% =========================================================================
N = size(PPAM,1); 
suma_columnas = sum(PPAM, 1);
MM = zeros(N, N);
for i = 1:N
    if suma_columnas(i) ~= 0
        MM(:, i) = PPAM(:, i) / suma_columnas(i);
    else
        MM(:, i) = 1 / N; 
    end
end
alpha = 0.85; 
I = eye(N); % Matriz identidad necesaria para el sistema lineal

% --- MODELO 1: PAGERANK CLÁSICO ---
v1 = ones(N, 1) / N; 
% Resolución matricial directa (Sistema Lineal)
x1 = (I - alpha * MM) \ ((1 - alpha) * v1);
x1 = x1 / sum(x1); % Normalización por seguridad

% --- MODELO 2: PAGERANK PERSONALIZADO (SEVici) ---
nodos_sevici = [7,11,21,25,26,28,30,32,50,58,59,63];
v2 = zeros(N, 1);
v2(nodos_sevici) = 1; 
v2 = v2 / sum(v2); 
% Resolución matricial directa (Sistema Lineal)
x2 = (I - alpha * MM) \ ((1 - alpha) * v2);
x2 = x2 / sum(x2); % Normalización por seguridad

% --- MOSTRAR RESULTADOS EN CONSOLA ---
fprintf('\n--- RESULTADOS MODELO 1 (red clásica) ---\n');
disp(x1);
fprintf('\n--- RESULTADOS MODELO 2 (red con SEVici) ---\n');
disp(x2);

% --- GRÁFICA COMPARATIVA ---
figure;
plot(1:N, x1, '-o', 'Color', [0 0.4470 0.7410], 'LineWidth', 2, 'MarkerFaceColor', [0 0.4470 0.7410]); 
hold on;
plot(1:N, x2, '-s', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
title('Impacto de las estaciones principales de SEVici en la red ciclista');
xlabel('Nº de nodo (intersección)');
ylabel('Nivel de importancia (PageRank)');
legend('Modelo 1: flujo normal', 'Modelo 2: flujo intermodal (SEVici)');
grid on;