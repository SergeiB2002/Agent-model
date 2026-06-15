% Описание:    Дискретизация пути Дабинса в последовательность путевых точек
% Вход:        dubins_info             Полная информация о пути Дабинса
% Вход:        ns                      Количество дискретных точек на начальной дуге
% Вход:        nl                      Количество дискретных точек на прямой линии
% Вход:        nf                      Количество дискретных точек на конечной дуге
% Выход:       dubins_x                Массив x-координат путевых точек
% Выход:       dubins_y                Массив y-координат путевых точек

function [dubins_x, dubins_y] = Dubins_Discret(dubins_info, ns, nl, nf)

% При определении начальных и конечных позиций и направлений скорости
% существует всего четыре типа путей Dubins:
% (1) LSL (Левый-Прямой-Левый),  (2) RSR (Правый-Прямой-Правый)
% (3) LSR (Левый-Прямой-Правый), (4) RSL (Правый-Прямой-Левый)

circle_centre_start_param = [-1, 1, -1, 1];                  % -1(L), 1(R)
circle_centre_finish_param = [-1, 1, 1, -1];                 % -1(L), 1(R)
param_s = circle_centre_start_param(dubins_info.traj.type);  % Параметры расчета центра начальной дуги
param_f = circle_centre_finish_param(dubins_info.traj.type); % Параметры расчета центра конечной дуги

%% Дискретизация начальной дуги в последовательность путевых точек
xc_s = dubins_info.start.xc;                                  % X-координата центра начальной дуги
yc_s = dubins_info.start.yc;                                  % Y-координата центра начальной дуги
R_s = dubins_info.start.R;                                    % Радиус начальной дуги
phi_sc = dubins_info.start.phi_c;                             % Азимутальный угол начальной точки
% phi_ex = dubins_info.start.phi_ex;                          % Азимутальный угол точки выхода
psi_s = dubins_info.start.psi;                                % Угол перемещения на начальной дуге
if psi_s == 0
    phi_s_temp = phi_sc;
else
    d_phi_s = -param_s * psi_s / ns;                          % Вычисление размера дискретного угла начальной дуги
    phi_s_temp = phi_sc : d_phi_s : phi_sc - param_s * psi_s; % Дискретизация угла перемещения на начальной дуге
end

dubins_xs = xc_s + R_s * cos(phi_s_temp);                     % Вычисление последовательности x-координат путевых точек на начальной дуге
dubins_ys = yc_s + R_s * sin(phi_s_temp);                     % Вычисление последовательности y-координат путевых точек на начальной дуге

%% Дискретизация конечной дуги в последовательность путевых точек
xc_f = dubins_info.finish.xc;                                 % X-координата центра конечной дуги
yc_f = dubins_info.finish.yc;                                 % Y-координата центра конечной дуги
R_f = dubins_info.finish.R;                                   % Радиус конечной дуги
% phi_fc = dubins_info.finish.phi_c;                          % Азимутальный угол конечной точки
phi_en = dubins_info.finish.phi_en;                           % Азимутальный угол точки входа
psi_f = dubins_info.finish.psi;                               % Угол перемещения на конечной дуге
if psi_f == 0
    phi_f_temp = phi_en;
else
    d_phi_f = -param_f * psi_f / nf;                          % Вычисление размера дискретного угла конечной дуги
    phi_f_temp = phi_en : d_phi_f : phi_en - param_f * psi_f; % Дискретизация угла перемещения на конечной дуге
end
dubins_xf = xc_f + R_f * cos(phi_f_temp);                     % Вычисление последовательности x-координат путевых точек на конечной дуге
dubins_yf = yc_f + R_f * sin(phi_f_temp);                     % Вычисление последовательности y-координат путевых точек на конечной дуге

%% Дискретизация прямой линии в последовательность путевых точек
x_ex = dubins_info.start.x_ex;                                % X-координата точки выхода
y_ex = dubins_info.start.y_ex;                                % Y-координата точки выхода
x_en = dubins_info.finish.x_en;                               % X-координата точки входа
y_en = dubins_info.finish.y_en;                               % Y-координата точки входа
if x_en == x_ex && y_en == y_ex                               % В случае, когда длина прямой линии равна 0
    dubins_xl = x_ex;
    dubins_yl = y_ex;
elseif x_en == x_ex && y_en ~= y_ex                           % В случае, когда прямая линия перпендикулярна оси X
    dubins_yl = y_ex : (y_en - y_ex) / nl : y_en;
    [~, m] = size(dubins_yl);
    dubins_xl = zeros(1, m) + x_en;
elseif x_en ~= x_ex && y_en == y_ex                           % В случае, когда прямая линия перпендикулярна оси Y
    dubins_xl = x_ex : (x_en - x_ex) / nl : x_en;
    [~, m] = size(dubins_xl);
    dubins_yl = zeros(1, m) + y_en;
else
    dubins_xl = x_ex : (x_en - x_ex) / nl : x_en;             % Вычисление последовательности x-координат путевых точек на прямой линии
    dubins_yl = y_ex : (y_en - y_ex) / nl : y_en;             % Вычисление последовательности y-координат путевых точек на прямой линии
end

%% Объединение всех путевых точек
dubins_x = [dubins_xs, dubins_xl, dubins_xf];
dubins_y = [dubins_ys, dubins_yl, dubins_yf];
end