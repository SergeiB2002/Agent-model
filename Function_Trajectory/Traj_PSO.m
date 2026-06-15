% Описание:    Применение алгоритма роя частиц для настройки радиусов начальных и конечных дуг каждого участков пути
% Вход:        TrajSeq                 Матрица информации о пути БПЛА
% Вход:        State                   Информация о путях полета для БПЛА
% Вход:        ObsInfo                 Информация о препятствиях
% Вход:        Property                Структура параметров планирования пути
% Выход:       TrajSeq_new             Матрица информации о пути БПЛА
% Выход:       flag                    Флаг результатов генерации пути

function [TrajSeq_new, flag] = Traj_PSO(TrajSeq, State, ObsInfo, Property)
%% Инициализация данных для алгоритма PSO
[dubins_num, ~] = size(TrajSeq);                               % Получение количества участков пути Дабисна
increment_num = dubins_num * 2;                                 % Вычисление количества приращений радиусов
number = 100;                                                 % Количество частиц
iter_max = 20;                                                % Максимальное количество итераций алгоритма PSO
demension = increment_num;                                    % Установка размерности пространства движения частиц
P_lim = zeros(demension, 2);                                   % Инициализация ограничений позиции роя частиц
V_lim = zeros(demension, 2);                                   % Инициализация ограничений скорости роя частиц
for i = 1:demension                                           % Установка ограничений роя частиц
    P_lim(i, 1) = 0;
    P_lim(i, 2) = Property.increment;
    V_lim(i, 1) = -0.1 * Property.radius;
    V_lim(i, 1) = 0.1 * Property.radius;
end
c1 = 0.8;                                                     % Коэффициент инерции
c2 = 0.3;                                                     % Коэффициент самообучения
c3 = 0.3;                                                     % Коэффициент коллективного обучения

%% Инициализация состояния роя частиц
position = zeros(number, demension);                           % Инициализация матрицы информации о позициях роя частиц
velocity = zeros(number, demension);                           % Инициализация матрицы информации о скоростях роя частиц
pos_par_best = zeros(number, demension);                       % Инициализация оптимальной позиции для каждой частицы
fit_par_best = zeros(number, 1) + inf;                         % Инициализация оптимального значения целевой функции для каждой частицы
fit_gro_history = zeros(iter_max, 1);                          % Инициализация минимального значения целевой функции для каждой итерации PSO
for n = 1:number
    for i = 1:demension
        position(n, i) = ...                                   % Случайная генерация позиции частиц
            P_lim(i, 1) + (P_lim(i, 2) - P_lim(i, 1)) * rand;
        velocity(n, i) = ...                                   % Случайная генерация скорости частиц
            V_lim(i, 1) + (V_lim(i, 2) - V_lim(i, 1)) * rand;
    end
end

%% Обновление состояния роя частиц
iter = 1;                                                     % Инициализация счетчика итераций
while iter <= iter_max                                        % Итерационный расчет PSO
    for n = 1:number                                          % Расчет информации для каждой частицы
        Increment = position(n, :);                           % Получение приращений
        [TrajSeq_new, flag] = Traj_Seq_Modification...         % Генерация модифицированного пути на основе первичного пути и приращений радиусов
            (TrajSeq, Increment, ObsInfo, Property);
        %Plot_Traj_Single(TrajSeq_new, ObsInfo, Property, 1)
        if flag ~= 0                                          % Если путь существует
            length = Traj_Length(TrajSeq_new);                % Вычисление длины пути
        end
        if flag == 2                                          % Если путь не пересекается с препятствиями
            fitness = abs(length - State.ideal_length);       % Вычисление значения целевой функции текущего пути, сгенерированного частицей
        else                                                % другие условия
            fitness = 1e10;                                   % Установка большего значения целевой функции
        end
        if fitness < fit_par_best(n)                          % Если текущее значение целевой функции меньше исторического минимума
            fit_par_best(n) = fitness;                        % Обновление минимального значения целевой функции частицы
            pos_par_best(n, :) = position(n, :);              % Обновление позиции минимального значения целевой функции частицы
        end
    end
    [fit_gro_best, index] = min(fit_par_best);                 % Обновление минимального значения целевой функции роя частиц
    pos_gro_best = pos_par_best(index, :);                     % Обновление позиции минимального значения целевой функции роя частиц
    fit_gro_history(iter) = fit_gro_best;                     % Запись минимального значения целевой функции для каждой итерации PSO

    velocity = ...                                            % Обновление направления скорости роя частиц
        c1 * velocity + ...                                     % Инерционный член
        c2 * rand * (pos_par_best - position) + ...                 % Член самообучения
        c3 * rand * (repmat(pos_gro_best, number, 1) - position);   % Член коллективного обучения
    for n = 1:number
        for i = 1:demension
            if velocity(n, i) > V_lim(i, 2)                     % Ограничение максимального значения скорости
                velocity(n, i) = V_lim(i, 2);
            end
            if velocity(n, i) < V_lim(i, 1)                     % Ограничение минимального значения скорости
                velocity(n, i) = V_lim(i, 1);
            end
        end
    end

    position = position + velocity;                             % Обновление позиции роя частиц
    for n = 1:number
        for i = 1:demension
            if position(n, i) > P_lim(i, 2)                     % Ограничение максимального значения позиции
                position(n, i) = P_lim(i, 2);
            end
            if position(n, i) < P_lim(i, 1)                     % Ограничение минимального значения позиции
                position(n, i) = P_lim(i, 1);
            end
        end
    end
    iter = iter + 1;                                            % Накопление счетчика

end

%% Генерация оптимизированного пути
[~, index] = min(fit_par_best);                                % получение лучшей частицы
Increment = pos_par_best(index, :);                            % позиция минимального значения целевой функции частицы (лучшие приращения)
[TrajSeq_new, flag] = Traj_Seq_Modification...                 % Генерация модифицированного пути, соответствующего лучшим приращениям
    (TrajSeq, Increment, ObsInfo, Property);

end