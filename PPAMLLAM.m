% 1. Generar matriz LLAM (Grafo Dual - Líneas)
% Multiplicamos M por su traspuesta y binarizamos
LLAM = double((M * M') > 0);

% Diagonal a cero
nL = size(LLAM, 1);
LLAM(1:nL+1:end) = 0;

% 2. Generar matriz PPAM (Grafo Primal - Puntos)
% Multiplicamos la traspuesta por M y binarizamos
PPAM = double((M' * M) > 0);

% Diagonal a cero
nP = size(PPAM, 1);
PPAM(1:nP+1:end) = 0;

% Mostrar resultados en consola
disp('Matriz LLAM (Dual):');
disp(LLAM);

disp('Matriz PPAM (Primal):');
disp(PPAM);