% Описание:    Инициализация базовой структуры пути Дабинса на основе начальной и конечной информации
% Вход:        start_info              Информация о начальной точке
% Вход:        finish_info             Информация о конечной точке
% Выход:       dubins_info             Базовая информация о пути Дабинса

function dubins_info = Dubins_Init(start_info, finish_info)

dubins_info.traj.type = 0;                                    % Тип пути Дабинса
dubins_info.traj.erro = 0;                                    % Маркер ошибки
dubins_info.traj.length = 0;                                  % Длина пути
dubins_info.traj.flag = 0;                                    % 0: Путь Дабинса
                                                            % 1: Касательный путь

%% Информация о начале пути
dubins_info.start.x = start_info(1);                          % X-координата начальной точки
dubins_info.start.y = start_info(2);                          % Y-координата начальной точки
dubins_info.start.phi = start_info(3);                        % Начальный угол курса
dubins_info.start.R = start_info(4);                          % Радиус начальной дуги
dubins_info.start.phi_c = 0;                                  % Азимутальный угол начальной точки
dubins_info.start.xc = 0;                                     % X-координата центра начальной дуги
dubins_info.start.yc = 0;                                     % Y-координата центра начальной дуги
dubins_info.start.phi_ex = 0;                                 % Азимутальный угол точки выхода
dubins_info.start.x_ex = 0;                                   % X-координата точки выхода
dubins_info.start.y_ex = 0;                                   % Y-координата точки выхода
dubins_info.start.psi = 0;                                    % Углы перемещения на начальной дуге

%% Информация о конце пути
dubins_info.finish.x = finish_info(1);                        % X-координата конечной точки
dubins_info.finish.y = finish_info(2);                        % Y-координата конечной точки
dubins_info.finish.phi = finish_info(3);                      % Конечный угол курса
dubins_info.finish.R = finish_info(4);                        % Радиус конечной дуги
dubins_info.finish.phi_c = 0;                                 % Азимутальный угол конечной точки
dubins_info.finish.xc = 0;                                    % X-координата центра конечной дуги
dubins_info.finish.yc = 0;                                    % Y-координата центра конечной дуги
dubins_info.finish.phi_en = 0;                                % Азимутальный угол точки входа
dubins_info.finish.phi_en1 = 0;                               % Угол курса точки входа
dubins_info.finish.x_en = 0;                                  % X-координата точки входа
dubins_info.finish.y_en = 0;                                  % Y-координата точки входа
dubins_info.finish.psi = 0;                                   % Углы перемещения на конечной дуге
end