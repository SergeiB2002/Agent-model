% Описание:  Формирование полной информации о пути на основе базовой информации о пути Дабинса и типа пути
% Вход:        dubins_info             Базовая информация о пути Дабинса
% Вход:        type                    Тип пути Дабинса
% Выход:       dubins_info             Полная информация о пути Дабинса

function dubins_info = Dubins_Generate(dubins_info,type)

dubins_info.traj.type=type;                                 % Установка типа пути
dubins_info.traj.erro=0;                                    % Сброс маркера ошибки

%% Вычисление параметров пути Dubins

circle_centre_start_param = [-1, 1,-1, 1];
circle_centre_finish_param =[-1, 1, 1,-1];
exit_point_angle_param_1 =  [-1, 1, 1,-1];
enter_point_angle_param_1 = [-1, 1, 1,-1];
exit_point_angle_param_2 =  [3*pi/2, pi/2, -pi/2, pi/2];
enter_point_angle_param_2 = [3*pi/2, pi/2, pi/2,  3*pi/2];
start_rotate_angle =        [-1, 1,-1, 1];
finish_rotate_angle =       [-1, 1, 1,-1];
tangent_type =              [-1,-1, 1, 1];

%% Вычисление информации о центрах начальной и конечной дуг
x_s = dubins_info.start.x;                                    % Получение x-координаты начальной точки
y_s = dubins_info.start.y;                                    % Получение y-координаты начальной точки
R_s = dubins_info.start.R;                                    % Получение радиуса начальной дуги
phi_s = dubins_info.start.phi;                                % Получение начального угла курса
param_s = circle_centre_start_param(type);                    % Получение параметра центра начальной дуги
xc_s = x_s - R_s * cos(phi_s + param_s * pi/2);               % Вычисление x-координаты центра начальной дуги
yc_s = y_s - R_s * sin(phi_s + param_s * pi/2);               % Вычисление y-координаты центра начальной дуги
dubins_info.start.phi_c = phi_s + param_s * pi/2;             % Установка азимутального угла начальной точки
dubins_info.start.xc = xc_s;                                  % Установка x-координаты центра начальной дуги
dubins_info.start.yc = yc_s;                                  % Установка y-координаты центра начальной дуги

if dubins_info.traj.flag == 0                                 % Вычисление информации о пути Дабинса
    x_f = dubins_info.finish.x;                               % Получение x-координаты конечной точки
    y_f = dubins_info.finish.y;                               % Получение y-координаты конечной точки
    R_f = dubins_info.finish.R;                               % Получение радиуса конечной дуги
    phi_f = dubins_info.finish.phi;                           % Получение конечного угла курса
    param_f = circle_centre_finish_param(type);               % Получение параметра центра конечной дуги
    xc_f = x_f - R_f * cos(phi_f + param_f * pi/2);           % Вычисление x-координаты центра конечной дуги
    yc_f = y_f - R_f * sin(phi_f + param_f * pi/2);           % Вычисление y-координаты центра конечной дуги
    dubins_info.finish.phi_c = phi_f + param_f * pi/2;        % Установка азимутального угла конечной точки
    dubins_info.finish.xc = xc_f;                             % Установка x-координаты центра конечной дуги
    dubins_info.finish.yc = yc_f;                             % Установка y-координаты центра конечной дуги

elseif dubins_info.traj.flag == 1                             % Вычисление информации о касательном пути
    xc_f = dubins_info.finish.xc;                             % Получение x-координаты центра конечной дуги
    yc_f = dubins_info.finish.yc;                             % Получение y-координаты центра конечной дуги
    R_f = dubins_info.finish.R;                               % Получение радиуса конечной дуги
end

%% Вычисление азимутальных углов выхода и входа
param_t=tangent_type(type);
param_ex1=exit_point_angle_param_1(type);
param_ex2=exit_point_angle_param_2(type);
param_en1=enter_point_angle_param_1(type);
param_en2=enter_point_angle_param_2(type);

c = sqrt((xc_s - xc_f)^2 + (yc_s - yc_f)^2);                  % Вычисление расстояния между центрами начальной и конечной дуг
if param_t == 1 && (R_s + R_f) > c || ...                     % Определение наличия допустимого решения
        param_t == -1 && abs(R_f - R_s) > c
    dubins_info.traj.erro = 1;                                % Установка маркера ошибки
    dubins_info.traj.length = 0;                              % Установка длины пути в 0 при отсутствии допустимых решений
    %warning('No Dubins Trajectory Exist\n')                  % Вывод информации об ошибке
    return;                                                   % Завершение функции
end
alpha = asin((R_f + param_t * R_s) / c);                      % Вычисление угла между линией центров и прямой линией
beta = atan2(yc_f - yc_s, xc_f - xc_s);                       % Вычисление угла между линией центров и осью X
phi_ex = beta + param_ex1 * alpha + param_ex2;                % Вычисление азимутального угла выхода
phi_en = beta + param_en1 * alpha + param_en2;                % Вычисление азимутального угла входа
phi_en1 = beta + param_en1 * alpha;                           % Вычисление угла курса входа
dubins_info.start.phi_ex = phi_ex;                            % Установка азимутального угла выхода
dubins_info.finish.phi_en = phi_en;                           % Установка азимутального угла входа
dubins_info.finish.phi_en1 = phi_en1;                         % Установка угла курса входа

%% Вычисление точек выхода и входа
x_ex = xc_s + R_s * cos(phi_ex);                              % Вычисление x-координаты точки выхода
y_ex = yc_s + R_s * sin(phi_ex);                              % Вычисление y-координаты точки выхода
x_en = xc_f + R_f * cos(phi_en);                              % Вычисление x-координаты точки входа
y_en = yc_f + R_f * sin(phi_en);                              % Вычисление y-координаты точки входа

dubins_info.start.x_ex = x_ex;                                % Установка x-координаты точки выхода
dubins_info.start.y_ex = y_ex;                                % Установка y-координаты точки выхода
dubins_info.finish.x_en = x_en;                               % Установка x-координаты точки входа
dubins_info.finish.y_en = y_en;                               % Установка y-координаты точки входа

%% Вычисление углов перемещения на начальной и конечной дугах
param_rs = start_rotate_angle(type);
psi_s = mod(pi/2 + param_rs * (phi_s - phi_ex), 2*pi);        % Вычисление угла перемещения на начальной дуге
dubins_info.start.psi = psi_s;                                % Установка угла перемещения на начальной дуге

if dubins_info.traj.flag == 0                                 % Вычисление информации о пути Дабинса
    param_rf = finish_rotate_angle(type);
    psi_f = mod(-pi/2 + param_rf * (-phi_f + phi_en), 2*pi);  % Вычисление угла перемещения на конечной дуге
    if abs(psi_f) < 3.1416*2 && abs(psi_f) > 3.1415*2         % Если абсолютное значение psi_f близко к 2*pi
        psi_f = 0;                                            % Установка psi_f в 0
    end
    dubins_info.finish.psi = psi_f;                           % Установка угла перемещения на конечной дуге

elseif dubins_info.traj.flag == 1                             % Вычисление информации о касательном пути
    psi_f = 0;
    dubins_info.finish.psi = psi_f;                           % Установка угла перемещения на конечной дуге в 0
    dubins_info.finish.phi = phi_en1;                         % Установка конечного угла курса как угла курса входа
    dubins_info.finish.x = x_en;                              % Установка x-координаты конечной точки
    dubins_info.finish.y = y_en;                              % Установка y-координаты конечной точки
end

%% Вычисление длины пути
cs = R_s * psi_s;                                             % Вычисление длины начальной дуги
l = sqrt((x_en - x_ex)^2 + (y_en - y_ex)^2);                  % Вычисление длины прямой линии
cf = R_f * psi_f;                                             % Вычисление длины конечной дуги
dubins_info.traj.length = cs + l + cf;                        % Установка длины пути
end


