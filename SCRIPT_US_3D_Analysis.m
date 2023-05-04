%% SCRIPT_3D_Group_Speed_Analysis.m makes a 3D plot showing the evolution of the free 
% surface over the course of an experiment at every X Pixel Value

%% Setup
clear all
clc
%%

load('UpStreamData.mat')


TimePerFrame = 1/30;

%% extract data
for mm = 1:1:length(UpStreamData.polyProcessed)
        xdat(mm,:) = UpStreamData.polyProcessed(mm).points(1,:);
        ydat(mm,:) = UpStreamData.polyProcessed(mm).points(2,:);
        tval(mm,:) = UpStreamData.polyProcessed(mm).Time*ones(size(xdat(mm,:))); 
end

%% Correcting Extraneous Data and Reformatting


smoothing1 = find(ydat <= 475);


for ii = 1:1:length(smoothing1)
    ydat(smoothing1(ii)) = ydat(smoothing1(ii) - 1);
end


%% Plotting Y Position Over Time for every X Pixel Value

figure()
for i = 1:1:length(xdat)
    plot3(xdat(:,i), tval(:,i), ydat(:,i))
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
colorbar

xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Certain X Pixels Over Whole Trial')
shading interp




%% Plotting Energy Density for Every Trial
figure()
surf(xdat, tval, ydat)
colorbar
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')
shading interp






    
