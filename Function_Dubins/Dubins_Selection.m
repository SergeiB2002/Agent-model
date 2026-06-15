% Описание:    Выбор путей в TrajCollect по определенному условию
% Вход:        TrajCollect             Матрица информации о путях БПЛА
% Вход:        ObsInfo                 Матрица информации о препятствиях
% Вход:        Property                Структура параметров планирования пути
% Вход:        stage                   Этап планирования пути
% Выход:       index                   Индекс выбранного пути (номер)
% Выход:       ObsCur                  Номер первого препятствия на каждом пути

function [index, ObsCur] = Dubins_Selection(TrajCollect, ObsInfo, Property, stage)

[n, ~] = size(TrajCollect);
[m, ~] = size(ObsInfo);
if stage == 1
    flag = Property.selection1;
else
    flag = Property.selection2;
end
switch flag
    % Выбор путей, которые не пересекаются с препятствиями
    case 1
        IndexTemp = zeros(1, Property.max_info_num);
        count = 0;
        for i = 1:n
            length = TrajCollect(i, 24);
            if length == 0
                continue;
            end
            obs_num = TrajCollect(i, 26);
            obs_index(1:5) = TrajCollect(i, 27:31);
            if obs_num == 0 && obs_index(1) == 0
                count = count + 1;
                IndexTemp(1, count) = i;
            end
            %Plot_Traj_Single(TrajCollect(i,:), ObsInfo, Property)
        end
        if count == 0
            index = 0;
        else
            index = zeros(1, count);
            index(1, :) = IndexTemp(1, 1:count);
        end

    % Выбор путей, у которых угол поворота не превышает 3 * pi/2
    case 2
        IndexTemp = zeros(1, Property.max_info_num);
        count = 0;
        for i = 1:n
            length = TrajCollect(i, 24);
            if length == 0
                continue;
            end
            psi_s = TrajCollect(i, 12);
            psi_f = TrajCollect(i, 23);
            if abs(psi_s) + abs(psi_f) < 3 * pi/2
                count = count + 1;
                IndexTemp(1, count) = i;
            end
        end
        if count == 0
            index = 0;
        else
            index = zeros(1, count);
            index(1, :) = IndexTemp(1, 1:count);
        end
        
    % Выбор путей, одновременно удовлетворяющих случаям 1 и 2
    case 3
        IndexTemp = zeros(1, Property.max_info_num);
        count = 0;
        for i = 1:n
            length = TrajCollect(i, 24);
            if length == 0
                continue;
            end
            obs_num = TrajCollect(i, 26);
            obs_index(1:5) = TrajCollect(i, 27:31);
            psi_s = TrajCollect(i, 12);
            psi_f = TrajCollect(i, 23);
            if obs_num == 0 && obs_index(1) == 0
                if abs(psi_s) + abs(psi_f) < 3 * pi/2
                    count = count + 1;
                    IndexTemp(1, count) = i;
                end
            end
            %Plot_Traj_Single(TrajCollect(i,:), ObsInfo, Property)
        end
        if count == 0
            index = 0;
        else
            index = zeros(1, count);
            index(1, :) = IndexTemp(1, 1:count);
        end
        
    % Выбор кратчайшего пути без препятствий
    case 4
        index = 0;
        length_min = 0;
        for i = 1:n
            obs_num = TrajCollect(i, 26);
            obs_index(1:5) = TrajCollect(i, 27:31);
            if obs_num == 0 && obs_index(1) == 0
                [length_min, index] = Dubins_Selection_Length...
                    (TrajCollect, length_min, index, i);
            end
        end
        
    % Выбор кратчайшего пути, удовлетворяющего ограничению по углу поворота
    case 5
        index = 0;
        length_min = 0;
        for i = 1:n
            psi_s = TrajCollect(i, 12);
            psi_f = TrajCollect(i, 23);
            if abs(psi_s) + abs(psi_f) < 3 * pi/2
                [length_min, index] = Dubins_Selection_Length...
                    (TrajCollect, length_min, index, i);
            end
        end
        
    % Выбор кратчайшего пути
    case 6
        index = 0;
        length_min = 0;
        for i = 1:n
            [length_min, index] = Dubins_Selection_Length...
                (TrajCollect, length_min, index, i);
        end
        
    % Выбор пути, удовлетворяющего ограничению по углу поворота и представляющего наименьшую угрозу
    case 7
        index = 0;
        length_min = 0;
        threat_min = 0;
        for i = 1:n
            psi_s = TrajCollect(i, 12);
            psi_f = TrajCollect(i, 23);
            if abs(psi_s) + abs(psi_f) < 3 * pi/2
                [threat_min, length_min, index] = Dubins_Selection_Threat...
                    (TrajCollect, ObsInfo, threat_min, length_min, index, i);
            end
        end
        
    % Выбор пути с наименьшей угрозой
    case 8
        index = 0;
        length_min = 0;
        threat_min = 0;
        for i = 1:n
            [threat_min, length_min, index] = Dubins_Selection_Threat...
                (TrajCollect, ObsInfo, threat_min, length_min, index, i);
        end

end

%% Получение номера первого препятствия на пути
obs_count = 0;
ObsCur = zeros(1, m);
for i = 1:n
    length = TrajCollect(i, 24);
    if length ~= 0
        obs_index(1:5) = TrajCollect(i, 27:31);
        obs_flag = 1;
        for j = 1:obs_count + 1
            if ObsCur(j) == obs_index(1) || ...
                    Property.obs_last == obs_index(1)
                obs_flag = 0;
            end
        end
        if obs_flag == 1
            obs_count = obs_count + 1;
            ObsCur(1, obs_count) = obs_index(1);
        end
    end
end
end