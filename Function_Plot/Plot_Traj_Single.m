% Описание:  Построение траектории БПЛА
% Вход:      TrajSeq                 Матрица информации о траектории БПЛА
% Вход:      ObsInfo                 Матрица информации о препятствиях
% Вход:      Property                Структура параметров планирования пути
% Вход:      flag                    Опция отображения альтернативных путей, 0: не отображать; 1: отображать

function [o1,l1]=Plot_Traj_Single(TrajSeq,ObsInfo,Property,flag)
%% Инициализация информации
scale=Property.scale;                                           % Установка масштаба отображения
[Traj_x,Traj_y]=Traj_Discrete(TrajSeq,Property);                % Получение дискретизированной последовательности путевых точек
[~,n1]=size(Traj_x);                                            % Получение количества путевых точек
[n2,~]=size(TrajSeq);                                           % Получение количества сегментов траектории
figure('name','Траектория БПЛА');
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

%% Построение траектории, начальной и конечной точек
l1=plot(Traj_x*scale,Traj_y*scale,'k');                         % Построение траектории
l1.LineWidth=1.5;                                               % Установка ширины линии
x_s=Traj_x(1);                                                  % Координата x начальной точки
y_s=Traj_y(1);                                                  % Координата y начальной точки
x_f=Traj_x(n1);                                                 % Координата x конечной точки
y_f=Traj_y(n1);                                                 % Координата y конечной точки
x_pt=[x_s,x_f];
y_pt=[y_s,y_f];
z_pt=[25000,25000];
pt=scatter3(x_pt*scale,y_pt*scale,z_pt*scale,80);               % Построение начальной и конечной точек
pt.MarkerFaceColor='r';
pt.MarkerEdgeColor='k';

%% Определение необходимости построения вспомогательных линий в зависимости от флага
if flag==1
    for i=1:n2
        theta=0:0.05:2*pi;
        xc_s=TrajSeq(i,7);                                      % Координата x центра начальной дуги
        yc_s=TrajSeq(i,8);                                      % Координата y центра начальной дуги
        R_s=TrajSeq(i,5);                                       % Радиус начальной дуги
        xs_temp=xc_s+R_s*cos(theta);
        ys_temp=yc_s+R_s*sin(theta);
        l2=plot(xs_temp*scale,ys_temp*scale,':b');              % Построение начальной дуги
        l2.LineWidth=0.5;
    end
end

%% Если БПЛА входит в зону препятствия (опасная зона), построение сжатого опасного круга
flag_invasion=0;
for i=1:n2
    if TrajSeq(i,25)==0
        continue;
    end
    if TrajSeq(i,32)==1&&...                                    % Если БПЛА вторгается в препятствие
            TrajSeq(i,16)<ObsInfo(TrajSeq(i,25),3)              % И радиус конечной дуги меньше радиуса препятствия
        xc_f=TrajSeq(i,18);                                     % Получение координаты x центра конечной дуги
        yc_f=TrajSeq(i,19);                                     % Получение координаты y центра конечной дуги
        R_f=TrajSeq(i,16);                                      % Получение радиуса конечной дуги
        theta=0:0.05:2*pi;
        xf_temp=xc_f+R_f*cos(theta);
        yf_temp=yc_f+R_f*sin(theta);
        l4=plot(xf_temp*scale,yf_temp*scale,'m');              % Построение конечной дуги
        l4.LineWidth=1;
        flag_invasion=1;
    end

end
%% Настройка параметров рисунка
set(gcf,'unit','inches','position',[0,0,6,4.5]);
set(gca,'FontName','Times New Roman','FontSize',12);
xlabel('$X/m$','Interpreter','latex');
ylabel('$Y/m$','Interpreter','latex');
zlabel('$Y/m$','Interpreter','latex');
xlim([-200,600]);
ylim([-300,350]);
grid on;
box on;
if flag_invasion==1&&flag==1
    L=legend([l1,o1,l4],{'Путь',...
        'Опасная зона','Сжатая область'});
    L.Location='northeast';
end
end