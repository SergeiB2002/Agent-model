% Описание:    Сохранение информации о пути Дабинса и информации о препятствиях на пути в массив
% Вход:        dubins_info             Информация о пути Дабинса
% Вход:        ObsSeries               Массив номеров препятствий
% Вход:        Property                Структура параметров планирования пути
% Выход:       TrajInfo                Массив информации о пути

function TrajInfo = Traj_Info_Array(dubins_info, ObsSeries, Property)

TrajInfo = zeros(1, Property.Info_length);
[~, c] = size(ObsSeries);                                      % Получение длины массива препятствий
count = 0;
for j = 1:c                                                   % Перебор каждого элемента в массиве препятствий
    if ObsSeries(1, j) == 0                                    % Если номер препятствия равен 0, это означает, что последующие элементы не записаны
        break;
    end
    count = count + 1;                                          % Накопление счетчика
end

%% Информация о начале пути
TrajInfo(1, 1) = dubins_info.traj.type;                        % Тип пути Дабинса
TrajInfo(1, 2) = dubins_info.start.x;                          % X-координата начальной точки
TrajInfo(1, 3) = dubins_info.start.y;                          % Y-координата начальной точки
TrajInfo(1, 4) = dubins_info.start.phi;                        % Начальный угол курса
TrajInfo(1, 5) = dubins_info.start.R;                          % Радиус начальной дуги
TrajInfo(1, 6) = dubins_info.start.phi_c;                      % Азимутальный угол начальной точки
TrajInfo(1, 7) = dubins_info.start.xc;                         % X-координата центра начальной дуги
TrajInfo(1, 8) = dubins_info.start.yc;                         % Y-координата центра начальной дуги
TrajInfo(1, 9) = dubins_info.start.phi_ex;                     % Азимутальный угол точки выхода
TrajInfo(1, 10) = dubins_info.start.x_ex;                      % X-координата точки выхода
TrajInfo(1, 11) = dubins_info.start.y_ex;                      % Y-координата точки выхода
TrajInfo(1, 12) = dubins_info.start.psi;                       % Угол перемещения на начальной дуге

%% Информация о конце пути
TrajInfo(1, 13) = dubins_info.finish.x;                        % X-координата конечной точки
TrajInfo(1, 14) = dubins_info.finish.y;                        % Y-координата конечной точки
TrajInfo(1, 15) = dubins_info.finish.phi;                      % Конечный угол курса
TrajInfo(1, 16) = dubins_info.finish.R;                        % Радиус конечной дуги
TrajInfo(1, 17) = dubins_info.finish.phi_c;                    % Азимутальный угол конечной точки
TrajInfo(1, 18) = dubins_info.finish.xc;                       % X-координата центра конечной дуги
TrajInfo(1, 19) = dubins_info.finish.yc;                       % Y-координата центра конечной дуги
TrajInfo(1, 20) = dubins_info.finish.phi_en;                   % Азимутальный угол точки входа
TrajInfo(1, 21) = dubins_info.finish.x_en;                     % X-координата точки входа
TrajInfo(1, 22) = dubins_info.finish.y_en;                     % Y-координата точки входа
TrajInfo(1, 23) = dubins_info.finish.psi;                      % Угол перемещения на конечной дуге

%% Длина пути
TrajInfo(1, 24) = dubins_info.traj.length;

%% Информация о препятствиях
TrajInfo(1, 25) = 0;                                           % Номер препятствия, которое нужно обойти в данный момент
TrajInfo(1, 26) = count;                                       % Количество препятствий, пересекающих путь
TrajInfo(1, 27) = ObsSeries(1, 1);                             % Номер 1-го препятствия
TrajInfo(1, 28) = ObsSeries(1, 2);                             % Номер 2-го препятствия
TrajInfo(1, 29) = ObsSeries(1, 3);                             % Номер 3-го препятствия
TrajInfo(1, 30) = ObsSeries(1, 4);                             % Номер 4-го препятствия
TrajInfo(1, 31) = ObsSeries(1, 5);                             % Номер 5-го препятствия

%% Другая информация
TrajInfo(1, 32) = Property.invasion;                           % Флаг вторжения в опасный круг
TrajInfo(1, 33) = 0;                                           % Флаг достижения конечной точки

end