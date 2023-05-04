%% SCRIPT_3D_Group_Speed_Analysis.m makes a 3D plot showing the evolution of the free 
% surface over the course of an experiment at every X Pixel Value

%% Setup
clear all
clc
%%

load('MVI_0098.mat')
load('MVI_0098_CIRCLE.mat')

TimePerFrame = 0.0167;
Wave_Period = 1.33;

omega_wave = (2*pi)/Wave_Period;
Cyl_Lead = min(Cyl_X(300,:));
Cyl_Tail = max(Cyl_X(350,:));
Cyl_Average = (Cyl_Tail + Cyl_Lead)/2;
Cyl_Diam = Cyl_Tail-Cyl_Lead;





%% extract data

for jj = 1:length(CylData)
    if isempty(CylData(jj).Frame)
        CylData(jj).Frame = CylData(jj-1).Frame+5;
        CylData(jj).Time = CylData(jj).Frame*TimePerFrame;
        CylData(jj).XDat = CylData(jj-1).XDat;
        CylData(jj).YDat = CylData(jj-1).YDat;
    end
end




for mm = 1:1:length(CylData)
        xdat(mm,:) = fittingPolyData.polyProcessed(mm).points(1,:);
        ydat(mm,:) = fittingPolyData.polyProcessed(mm).points(2,:);
        tval(mm,:) = fittingPolyData.polyProcessed(mm).Time*ones(size(xdat(mm,:)));
        Cyl_tval(mm,:) = CylData(mm).Time*ones(size(CylData(mm).XDat));
        Cyl_X(:,mm) = CylData(mm).XDat;
        Cyl_Y(:,mm) = CylData(mm).YDat;
        
end

%% Correcting Extraneous Data and Reformatting


smoothing1 = find(ydat <= 20);
smoothing2 = find(ydat >= 215);

for ii = 1:1:length(smoothing1)
    ydat(smoothing1(ii)) = ydat(smoothing1(ii) - 1);
end

for ii = 1:1:length(smoothing2)
    ydat(smoothing2(ii)) = ydat(smoothing2(ii) - 1);
end

        
%% Transposing Cylinder Data for Formatting

Cyl_X = Cyl_X';
Cyl_Y = Cyl_Y';






%% Limiting Trials to Better See Output

figure()
surf((xdat(300:350,:)-Cyl_Average*ones(size(xdat(300:350,:))))/Cyl_Diam,omega_wave*tval(300:350,:),ydat(300:350,:))
hold on
plot3((min(Cyl_X(300,:))*ones(length(Cyl_X(300:350)))-Cyl_Average*ones(length(Cyl_X(300:350))))/Cyl_Diam, omega_wave*Cyl_tval(300:350), 200*ones(length(Cyl_X(300:350))))
plot3((Cyl_Average*ones(length(Cyl_X(300:350)))-Cyl_Average*ones(length(Cyl_X(300:350))))/Cyl_Diam, omega_wave*Cyl_tval(300:350), 200*ones(length(Cyl_X(300:350))))
plot3((max(Cyl_X(350,:))*ones(length(Cyl_X(300:350)))-Cyl_Average*ones(length(Cyl_X(300:350))))/Cyl_Diam, omega_wave*Cyl_tval(300:350), 200*ones(length(Cyl_X(300:350))))

colorbar

xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Certain X Pixels Over Whole Trial')
shading interp










    
