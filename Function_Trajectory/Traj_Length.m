% Описание:    Вычисление длины пути
% Вход:        TrajSeq                 Матрица последовательности пути БПЛА
% Выход:       length                  Длина пути

function length = Traj_Length(TrajSeq)
[dubins_num, ~] = size(TrajSeq);                                   % Получение количества сегментов в пути
length = 0;                                                       % Инициализация длины пути
for i = 1:dubins_num                                              % Перебор всех сегментов пути
    length = length + TrajSeq(i, 24);                             % Накопление длины каждого сегмента
end
end