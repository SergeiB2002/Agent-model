% Описание:    Использование алгоритма роя частиц для настройки радиусов начальных и конечных дуг пути, 
%               чтобы длина пути была максимально близка к ожидаемой длине пути
% Вход:        length                  Ожидаемая длина пути
% Вход:        dubins_info             Базовая информация о пути Дабинса
% Выход:       fit_gro_history         Минимальное значение целевой функции для каждой итерации PSO
% Выход:       dubins_temp             Оптимизированная информация о пути Дабинса

function [fit_gro_history,dubins_temp] = Dubins_PSO(length,dubins_info)
if dubins_info.traj.length > length
    error('Нет доступного решения\n');
end
%% Инициализация данных для алгоритма PSO
number = 30;                                                % Количество частиц
demension = 2;                                              % Размерность пространства движения частиц
iter_max = 20;                                              % Максимальное количество итераций алгоритма PSO
R_s = dubins_info.start.R;                                  % Получение минимального радиуса начальной дуги
R_f = dubins_info.finish.R;                                 % Получение минимального радиуса конечной дуги
type = dubins_info.traj.type;                               % Получение типа пути Дабинса
P_lim = [R_s, R_s*5; R_f, R_f*5];                           % Определение ограничений позиции роя частиц
V_lim = 0.1 * [-R_s, R_s; -R_f, R_f];                       % Определение ограничений скорости роя частиц
c1 = 0.8;                                                   % Коэффициент инерции
c2 = 0.5;                                                   % Коэффициент самообучения
c3 = 0.5;                                                   % Коэффициент коллективного обучения

%% Инициализация состояния роя частиц
position = zeros(number, demension);                        % Инициализация матрицы информации о позициях роя частиц
velocity = zeros(number, demension);                        % Инициализация матрицы информации о скоростях роя частиц
pos_par_best = zeros(number, demension);                    % Инициализация оптимальной позиции для каждой частицы
fit_par_best = zeros(number, 1) + inf;                      % Инициализация оптимального значения целевой функции для каждой частицы
fit_gro_history = zeros(iter_max, 1);                       % Инициализация минимального значения целевой функции для каждой итерации PSO
for n = 1:number
    for i = 1:demension
        position(n,i) = ...                                 % Случайная генерация позиции частиц
            P_lim(i,1) + (P_lim(i,2) - P_lim(i,1)) * rand;
        velocity(n,i) = ...                                 % Случайная генерация скорости частиц
            V_lim(i,1) + (V_lim(i,2) - V_lim(i,1)) * rand;
    end
end

%% Обновление состояния роя частиц
iter = 1;                                                   
while iter <= iter_max                                      
    dubins_temp = dubins_info;                              % Формирование временной структуры Дабинса для итерации
    for n = 1:number                                        % Расчет информации для каждой частицы
        dubins_temp.start.R = position(n,1);                % X-координата частицы является радиусом начальной дуги
        dubins_temp.finish.R = position(n,2);               % Y-координата частицы является радиусом конечной дуги
        dubins_temp = Dubins_Generate(dubins_temp, type);   % Формирование пути Дабинса, соответствующего частице
        fitness = abs(length - dubins_temp.traj.length);    % Расчет значения целевой функции частицы
        if fitness < fit_par_best(n)                        % Если текущее значение целевой функции меньше исторического минимума
            fit_par_best(n) = fitness;                      % Обновление минимального значения целевой функции частицы
            pos_par_best(n,:) = position(n,:);              % Обновление позиции минимального значения целевой функции частицы
        end
    end
    [fit_gro_best, index] = min(fit_par_best);              % Обновление минимального значения целевой функции роя частиц
    pos_gro_best = pos_par_best(index,:);                   % Обновление позиции минимального значения целевой функции роя частиц
    fit_gro_history(iter) = fit_gro_best;                   % Запись минимального значения целевой функции для каждой итерации PSO
    
    %      if iter > 1
    %          if abs(fit_gro_best - fit_gro_history(iter-1)) < 1
    %              return;
    %          end
    %      end
    
    dubins_temp.start.R = pos_par_best(index,1);            % X-координата частицы является радиусом начальной дуги
    dubins_temp.finish.R = pos_par_best(index,2);           % Y-координата частицы является радиусом конечной дуги
    dubins_temp = Dubins_Generate(dubins_temp, type);       % Формирование пути Дабинса, соответствующего частице
    
    velocity = ...                                          % Обновление направления скорости роя частиц
        c1 * velocity + ...                                 % Инерционный член
        c2 * rand * (pos_par_best - position) + ...         % Член самообучения
        c3 * rand * (repmat(pos_gro_best, number, 1) - position); % Член коллективного обучения
    for n = 1:number
        for i = 1:demension
            if velocity(n,i) > V_lim(i,2)                   % Ограничение максимального значения скорости
                velocity(n,i) = V_lim(i,2);
            end
            if velocity(n,i) < V_lim(i,1)                   % Ограничение минимального значения скорости
                velocity(n,i) = V_lim(i,1);
            end
        end
    end
    
    position = position + velocity;                         % Обновление позиции роя частиц
    for n = 1:number
        for i = 1:demension
            if position(n,i) > P_lim(i,2)                   % Ограничение максимального значения позиции
                position(n,i) = P_lim(i,2);
            end
            if position(n,i) < P_lim(i,1)                   % Ограничение минимального значения позиции
                position(n,i) = P_lim(i,1);
            end
        end
    end
    iter = iter + 1;                                        % Накопление счетчика
end
end