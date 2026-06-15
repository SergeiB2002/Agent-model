% Описание:    Выбор кратчайшего пути
% Вход:        TrajCollect             Матрица информации о путях БПЛА
% Вход:        i                       Номер строки в TrajCollect
% Вход/Выход:  length_min              Минимальная длина
% Вход/Выход:  index                   Индекс выбранного пути (номер)

function [length_min, index] = Dubins_Selection_Length(TrajCollect, length_min, index, i)
    length = TrajCollect(i, 24);

    if length == 0
        return;
    end

    if length_min == 0
        length_min = length;
        index = i;
    end

    if length_min > length
        length_min = length;
        index = i;
    end
end