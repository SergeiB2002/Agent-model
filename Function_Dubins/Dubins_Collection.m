% Описание:    Формирование информации о путях для всех типов (LSL, RSR, LSR, RSL) на основе базовой информации о пути Дабинса
% Вход:        dubins_info             Базовая информация о пути Дабинса
% Вход:        ObsInfo                 Информация о препятствиях
% Вход:        obs_index               Номер препятствия, которое нужно обойти в данный момент
% Вход:        Property                Структура параметров планирования пути
% Выход:       TrajCollect             Информация о путях всех типов

function TrajCollect = Dubins_Collection(dubins_info, ObsInfo, obs_index, Property)
TrajCollect = zeros(4, Property.Info_length);                          % Инициализация матрицы информации о путях всех типов
for type = 1:4                                                         % Перебор каждого типа пути Дабинса
    dubins_info = Dubins_Generate(dubins_info, type);                  % Генерация полной информации о пути на основе базовой информации и типа пути
    if dubins_info.traj.length ~= 0                                    % Если длина сгенерированной траектории не равна 0, это указывает на существование траектории
        ObsSeries = Dubins_Obs_Check(dubins_info, ObsInfo, Property);  % Выполнение обнаружения препятствий на текущем пути
    else
        continue;
    end
    TrajInfo = Traj_Info_Array(dubins_info, ObsSeries, Property);      % Запись информации о пути Дабинса и информации о препятствиях на пути в массив
    TrajInfo(1, 25) = obs_index;                                       % Запись номера текущего препятствия, которое нужно обойти
    TrajCollect(type, :) = TrajInfo(1, :);                             % Сохранение информации о путях всех типов
end

end