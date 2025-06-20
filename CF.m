
function [J,X]=CF(X,~)

J=zeros(size(X,1),3);

for x=1:size(X,1)
    % Parámetros del controlador
    %Kp = 0.8; Ki = 0.015; Kd = 0.3; Ka = 0.05;
    Kp=X(x,1);
    Ki=X(x,2);
    Kd=X(x,3);
    Ka=X(x,4);
    % Guardar en CSV que Python leerá
    params = {'Kp','Ki','Kd','Ka'; Kp, Ki, Kd, Ka};
    writecell(params, 'pid_params.csv')

    % Ejecutar Python desde MATLAB (asegúrate de haber configurado pyenv)
    %terminate(pyenv)
    %pyenv('Version',...
    %    'C:\Users\greyn\Documents\Control2025GECCO\interpretable-control-competition-main\ic39\Scripts\python.exe',...
     %   'ExecutionMode','OutOfProcess');
    py.PM.main()

    % Leer métricas de salida
    results = readmatrix('resultado.csv');
    frames_survived = results(1,1);
    goals_scored    = results(1,2);
    goals_conceded  = results(1,3);

    J(x,:)=[-frames_survived,-goals_scored,goals_conceded];
end