% Описание:  Построение альтернативных и кооперативных траекторий всех БПЛА
% Вход:      Coop_State              Массив структур с информацией о траекториях БПЛА
% Вход:      ObsInfo                 Матрица информации о препятствиях
% Вход:      Property                Структура параметров планирования пути
% Вход:      flag                    Опция отображения альтернативных путей, 0: не отображать; 1: отображать
% Вход:      demo                    Индекс демонстрационного примера

function Plot_Traj_Coop(Coop_State,ObsInfo,Property,flag,demo)
%% Инициализация информации
[~,n]=size(Coop_State);
scale=Property.scale;                                               % Установка масштаба отображения
px=zeros(1,2*n);
py=zeros(1,2*n);
figure;
hold on;

%% Построение препятствий
theta=0:0.05:2*pi;
[obs_num,~]=size(ObsInfo);
for i=1:obs_num
    xo_temp=ObsInfo(i,1)+ObsInfo(i,3)*cos(theta);
    yo_temp=ObsInfo(i,2)+ObsInfo(i,3)*sin(theta);
    o1=plot(xo_temp*scale,yo_temp*scale,'r');
    o1.LineWidth=1.5;
    s=sprintf('%d',i);
    text(ObsInfo(i,1)*scale,ObsInfo(i,2)*scale,s);
end

%% Построение траекторий, начальных и конечных точек
for i=1:n
    if flag==1                                                      % Построение альтернативных траекторий
        [~,m]=size(Coop_State(i).TrajSeqCell);                      % Получение количества траекторий в TrajSeqCell
        for j=1:m                                                   % Перебор каждой траектории
            [Traj_x,Traj_y]=Traj_Discrete...                        % Получение дискретизированной последовательности путевых точек
                (Coop_State(i).TrajSeqCell{j},Property);
            hold on;
            l2=plot(Traj_x*scale,Traj_y*scale,'b');                 % Построение альтернативной траектории
            l2.LineWidth=1;                                         % Установка ширины линии
            l2.Color(4)=0.3;                                        % Установка прозрачности
        end
    end
    [~,c]=size(Traj_x);                                             % Получение количества дискретных точек
    px(i)=Traj_x(1);                                                % Получение координаты x начальной точки
    py(i)=Traj_y(1);                                                % Получение координаты y начальной точки
    px(n+i)=Traj_x(c);                                              % Получение координаты x конечной точки
    py(n+i)=Traj_y(c);                                              % Получение координаты y конечной точки
end
pt=scatter(px*scale,py*scale,80);                                   % Построение начальных и конечных точек
pt.MarkerFaceColor='r';
pt.MarkerEdgeColor='k';

for i=1:n                                                           % Построение кооперативной траектории каждого БПЛА
    [Traj_x,Traj_y]=Traj_Discrete...
        (Coop_State(i).TrajSeq_Coop,Property);                      % Получение дискретизированной последовательности путевых точек
    hold on;
    l1=plot(Traj_x*scale,Traj_y*scale,'k');                         % Построение кооперативной траектории
    l1.LineWidth=1.5;                                               % Установка ширины линии
end

%% Настройка параметров изображения
switch demo
    case 1
        set(gcf,'unit','inches','position',[0,0,6,4.5]);
        xlim([-150,600]); 
        ylim([-250,350]);
    case 2
        set(gcf,'unit','inches','position',[0,0,12,4]);
        xlim([-50,1050]);
        ylim([-100,300]);
end

set(gca,'FontName','Times New Roman','FontSize',12);
xlabel('$X/m$','Interpreter','latex');
ylabel('$Y/m$','Interpreter','latex');
zlabel('$Y/m$','Interpreter','latex');
grid on;
box on;
L=legend([l1,l2,o1],{'Групповой путь',...
    'Альтернативный путь','Опасная зона'});
L.Location='northeast';
L.FontSize=12;

end