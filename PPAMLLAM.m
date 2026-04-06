% Definición de la matriz LPIM (Line-Point Incidence Matrix)
% Fuente: Ecuación (A.5) del documento Jiang (2008)
% Filas: Líneas (a, b, c, d, e, f, g)
% Columnas: Puntos (1 a 15)

% Visualizar la matriz
disp('Matriz LPIM cargada:');
disp(M);
%% 2. Calcular LLAM (Line-Line Adjacent Matrix)
% Fórmula del paper: LLAM = LPIM * LPIM' (Ec. A.5 texto final)
% Significado: Si el producto es > 0, las líneas comparten al menos un punto.

% A) Multiplicación matricial por la traspuesta
LLAM_raw = M * M';

% B) Convertir a binario (1 si hay conexión, 0 si no)
LLAM = double(LLAM_raw > 0);

% C) "Asignar cero a los elementos diagonales" (Fuente: Nota en pag 4)
nLines = size(LLAM, 1);
LLAM(1:nLines+1:end) = 0; 

% Mostrar resultado
disp('--- Matriz LLAM Generada (Línea-Línea) ---');
disp(LLAM);

%% 3. Calcular PPAM 

% A) Multiplicación de traspuesta por la matriz original
PPAM_raw = M' * M;

% B) Convertir a binario
PPAM = double(PPAM_raw > 0);

% C) Asignar cero a la diagonal
nPoints = size(PPAM, 1);
PPAM(1:nPoints+1:end) = 0;

% Mostrar resultado
disp('--- Matriz PPAM Generada (Punto-Punto) ---');
disp(PPAM);