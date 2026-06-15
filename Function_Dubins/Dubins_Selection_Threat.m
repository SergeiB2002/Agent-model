% Описание:    Выбор пути с наименьшей угрозой
% Вход:        TrajCollect             Матрица информации о путях БПЛА
% Вход:        ObsInfo                 Матрица информации о препятствиях
% Вход:        i                       Номер строки в TrajCollect
% Вход/Выход:  threat_min              Минимальная угроза
% Вход/Выход:  length_min              Минимальная длина
% Вход/Выход:  index                   Индекс выбранного пути (номер)

function [threat_min, length_min, index] = Dubins_Selection_Threat...
    (TrajCollect, ObsInfo, threat_min, length_min, index, i)

xc = TrajCollect(i, 7);
yc = TrajCollect(i, 8);
R = TrajCollect(i, 5);
length = TrajCollect(i, 24);
obs_index(1:5) = TrajCollect(i, 27:31);

if length == 0
    return;
end

if obs_index(1) ~= 0
    x_obs = ObsInfo(obs_index(1), 1);
    y_obs = ObsInfo(obs_index(1), 2);
    R_obs = ObsInfo(obs_index(1), 3);
    threat = R + R_obs - sqrt((xc - x_obs)^2 + (yc - y_obs)^2);
    if threat < 0
        threat = 0;
    end
    if threat_min == 0 && i == 1
        threat_min = threat;
        index = i;
    end
    if threat_min > threat
        threat_min = threat;
        index = i;
    end
else
    threat_min = 0;
    if length_min == 0
        length_min = length;
        index = i;
    end
    if length_min > length
        length_min = length;
        index = i;
    end
end

end