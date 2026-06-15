% Описание:    Обновление скоординированного состояния полета для БПЛА
% Вход:        TrajSeqCell             Доступные пути для БПЛА
% Вход:        state                   Информация о путях полета для БПЛА
% Вход:        ObsInfo                 Матрица информации о препятствиях
% Вход:        Property                Структура параметров планирования пути
% Выход:       state                   Структура информации о путях полета для БПЛА

function State = Coop_State_Update(TrajSeqCell, State, ObsInfo, Property)

[~, n] = size(TrajSeqCell);                                    % Получение количества путей
State.traj_length = zeros(n, 1);                               % Инициализация массива длин путей
State.TrajSeqCell = TrajSeqCell;                              % Сохранение ячейки доступных путей для БПЛА

%% Получение информации о путях
for i = 1:n                                                   % Перебор каждого пути
   length = Traj_Length(TrajSeqCell{1,i});                    % Вычисление длины пути
   State.traj_length(i,1) = length;                           % Сохранение длины пути

   %% Получение самого длинного и самого короткого путей 
   if i == 1                                                  % Если это первый путь
       State.traj_length_max = length;                        % обновление длины самого длинного пути
       State.traj_length_min = length;                        % обновление длины самого короткого пути
   end
   if length > State.traj_length_max
       State.traj_length_max = length;                        % обновление длины самого длинного пути
   end
   if length < State.traj_length_min
       State.traj_length_min = length;                        % обновление длины самого короткого пути
   end

   %% Ожидаемая длина пути должна находиться в интервале между двумя базовыми длинами путей
   % Поиск пути, который короче и ближе всего к ожидаемой длине пути
   if length < State.ideal_length
       if State.traj_index_bottom == 0
           State.traj_index_bottom = i;
       elseif length > State.traj_length...
               (State.traj_index_bottom)
           State.traj_index_bottom = i;
       end
   end
   % Поиск пути, который длиннее и ближе всего к ожидаемой длине пути
   if length > State.ideal_length
       if State.traj_index_top == 0
           State.traj_index_top = i;
       elseif length < State.traj_length...
               (State.traj_index_top)
           State.traj_index_top = i;
       end
   end
end

%% Фомирование кооперативного пути
% При отсутствии "нижнего" пути, непосредственный вывод "верхнего" пути
if State.traj_index_bottom == 0
    State.TrajSeq_Coop = State.TrajSeqCell{State.traj_index_top};
    State.optim_length = Traj_Length(State.TrajSeq_Coop);
    return;
end

TrajSeq = State.TrajSeqCell{State.traj_index_bottom};
[m, ~] = size(TrajSeq);
invasion_bottom = 0;
for i = 1:m
    if TrajSeq(i,32) == 1
       invasion_bottom = 1;
    end
end

if invasion_bottom == 1
    TrajSeq_new = TrajSeq;
    flag = 1;
else
    % Использование алгоритма роя частиц для настройки радиусов начальных и конечных дуг каждого сегмента пути,
    % чтобы длина пути была максимально близка к ожидаемой длине пути
    [TrajSeq_new, flag] = Traj_PSO(TrajSeq, State, ObsInfo, Property);
end

if flag == 0
    TrajSeq_new = TrajSeq;
end

length_bottom = Traj_Length(TrajSeq_new);                     % Вычисление длины "нижнего" пути

if State.traj_index_top ~= 0                                  % При наличии "верхнего" пути
    length_top = Traj_Length...                               % Вычисление длины "верхнего" пути
        (State.TrajSeqCell{State.traj_index_top});
    % Сравнение "нижнего" и "верхнего" путей, чтобы определить, какой из них имеет длину, наиболее близкую к ожидаемой длине пути
    if abs(length_bottom - State.ideal_length) > abs(length_top - State.ideal_length)
        % Сохранение пути с наиболее близкой длиной в TrajSeq_Coop
        State.TrajSeq_Coop = State.TrajSeqCell{State.traj_index_top};
    else
        State.TrajSeq_Coop = TrajSeq_new;
    end
% Нет "верхнего" пути, и ожидаемая длина пути больше всех длин путей
else
    % Нет необходимости сравнивать, просто установка оптимизированного пути как кооперативного пути
    State.TrajSeq_Coop = TrajSeq_new;
end

State.optim_length = Traj_Length(State.TrajSeq_Coop);         % Вычисление длины кооперативного пути
end