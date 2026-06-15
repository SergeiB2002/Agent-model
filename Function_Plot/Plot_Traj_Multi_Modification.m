% Описание:  Построение всех путей а также их модифицированных версий
% Вход:      TrajSeqCell             Ячейка с информацией о траекториях БПЛА
% Вход:      ObsInfo                 Матрица информации о препятствиях
% Вход:      Property                Структура параметров планирования пути

function Plot_Traj_Multi_Modification(TrajSeqCell,ObsInfo,Property)
[~,n]=size(TrajSeqCell);                                            % Получение количества траекторий
scale=Property.scale;                                               % Получение масштаба отображения
for i=1:n
    TrajSeq=TrajSeqCell{1,i};
    [dubins_num,~]=size(TrajSeq);                                   % Получение количества сегментов пути Дабинса
    increment_num=dubins_num*2;                                     % Вычисление количества приращений
                                                                    % (приращения радиусов начальной и конечной дуг)
    Increment=zeros(1,increment_num);                               % Инициализация массива приращений радиусов
    if i==1
        [o1,l1]=Plot_Traj_Single(TrajSeq,ObsInfo,Property,0);       % Построение базового изображения и стандартных путей
    else
        [Traj_x,Traj_y]=Traj_Discrete(TrajSeq,Property);            % Получение дискретизированной последовательности путевых точек
        hold on;
        l1=plot(Traj_x*scale,Traj_y*scale,'k');                     % Построение основных траекторий
        l1.LineWidth=1.5;
    end
    
    for j=1:100                                                     % Циклическая генерация модифицированных путей
        for k=1:increment_num
            Increment(k)=rand*Property.increment;                   % Случайная генерация положительных приращений
        end
        [TrajSeq_new,flag]=Traj_Seq_Modification...                 % Генерация новой матрицы последовательности пути на основе приращений
            (TrajSeq,Increment,ObsInfo,Property);
        [dubins_num,~]=size(TrajSeq_new);                           % Получение количества сегментов пути Дабинса
        if flag==2&&TrajSeq_new(dubins_num,23)<6                    % Если путь не пересекается с препятствиями и конечная дуга < 6 рад
            hold on;                                                % Построение модифицированных путей на том же рисунке
            [Traj_x,Traj_y]=Traj_Discrete(TrajSeq_new,Property);    % Получение дискретизированной последовательности путевых точек
            l2=plot(Traj_x*scale,Traj_y*scale,'k');                 % Построение модифицированных путей
            l2.LineWidth=0.5;                                       % Установка ширины линии
            l2.Color(4)=0.2;                                        % Установка прозрачности линии
        end
    end
end
L=legend([l1,l2,o1],{'Базовый путь',...
    'Модифицированный путь','Опасная зона'});
L.Location='northeast';
L.FontSize=12;
end