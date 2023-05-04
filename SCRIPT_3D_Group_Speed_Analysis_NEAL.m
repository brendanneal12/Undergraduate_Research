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




%% Plotting Y Position Over Time for every X Pixel Value

figure(1)
for i = 1:1:length(xdat)
    plot3(xdat(:,i), tval(:,i), ydat(:,i) )
    hold on
end

xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')


%% Plotting Energy Density for Every Trial

figure()
surf(xdat, tval, ydat)
hold on
colorbar
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')
shading interp

%% Limiting Trials to Better See Output

figure()
surf(xdat(300:350,:),tval(300:350,:),ydat(300:350,:))
hold on
surf(Cyl_X(300:350,:), Cyl_tval(300:350,:), ones(size(Cyl_X(300:350,:))))
colorbar

xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Certain X Pixels Over Whole Trial')
shading interp

%% Plotting Cylinder Over Time
figure(4)
for i = 1:1:length(Cyl_tval)
    plot3(Cyl_X(i,:), Cyl_tval(i,:), Cyl_Y(i,:))
    hold on
end
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Representation of Cylinder Over Whole Trial')

%% Combining Cylinder Plot with WaveShape Plots

figure(5)
for i = 1:1:length(xdat)
    plot3(xdat(:,i), tval(:,i), ydat(:,i))
    hold on
end

for i = 1:1:length(Cyl_tval)
    plot3(Cyl_X(i,:), Cyl_tval(i,:), ones(size(Cyl_X(i,:))))
    hold on
end

xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')

%% Plotting Cylinder Energy Density

figure(6)
surf(Cyl_X, Cyl_tval, Cyl_Y)
colorbar
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')
shading interp

%% Plotting Energy Density for Every Trial

figure(7)
surf(xdat, tval, ydat)
hold on
surf(Cyl_X, Cyl_tval, ones(size(Cyl_X)))
colorbar
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')
shading interp






    
