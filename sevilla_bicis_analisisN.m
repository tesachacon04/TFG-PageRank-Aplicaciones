% =========================================================================
% TFG: ANÁLISIS DE LA RED DE CARRILES BICI (GRAFO PRIMAL - CRUCES)
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

% --- MODELO 1: PAGERANK CLÁSICO ---
v1 = ones(N, 1) / N; 
G1 = alpha * MM + (1 - alpha) * (v1 * ones(1, N));
x1 = ones(N, 1) / N; 
for iter = 1:100
    x1 = G1 * x1;
end

% --- MODELO 2: PAGERANK PERSONALIZADO (SEVici) ---
nodos_sevici = [7,11,21,25,26,28,30,32,50,58,59,63];
v2 = zeros(N, 1);
v2(nodos_sevici) = 1; 
v2 = v2 / sum(v2); 

G2 = alpha * MM + (1 - alpha) * (v2 * ones(1, N));
x2 = ones(N, 1) / N; 
for iter = 1:100
    x2 = G2 * x2;
end

% --- MOSTRAR RESULTADOS EN CONSOLA ---
fprintf('\n--- RESULTADOS MODELO 1 (Red Clásica) ---\n');
disp(x1);

fprintf('\n--- RESULTADOS MODELO 2 (Red con SEVici) ---\n');
disp(x2);

% --- GRÁFICA COMPARATIVA ---
figure;
plot(1:N, x1, '-o', 'Color', [0 0.4470 0.7410], 'LineWidth', 2, 'MarkerFaceColor', [0 0.4470 0.7410]); 
hold on;
plot(1:N, x2, '-s', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);

title('Impacto de las Estaciones Principales de SEVici en la Red Ciclista');
xlabel('Nº de Nodo (Intersección)');
ylabel('Nivel de Importancia (PageRank)');
legend('Modelo 1: Flujo Normal', 'Modelo 2: Flujo Intermodal (SEVici)');
grid on;
