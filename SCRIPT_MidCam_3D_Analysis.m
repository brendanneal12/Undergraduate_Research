%% SCRIPT_3D_Group_Speed_Analysis.m makes a 3D plot showing the evolution of the free 
% surface over the course of an experiment at every X Pixel Value

%% Setup
clear all
clc
%%

load('MidCamData.mat')


TimePerFrame = 1/30;

%% extract data
%% extract data
for mm = 1:1:length(MidCamData.polyProcessed)
        xdatleft(mm,:) = MidCamData.polyProcessed(mm).Left.points(1,:);
        ydatleft(mm,:) = MidCamData.polyProcessed(mm).Left.points(2,:);
        tvalleft(mm,:) = MidCamData.polyProcessed(mm).Left.Time*ones(size(xdatleft(mm,:)));
        
        xdatright(mm,:) = MidCamData.polyProcessed(mm).Right.points(1,:);
        ydatright(mm,:) = MidCamData.polyProcessed(mm).Right.points(2,:);
        tvalright(mm,:) = MidCamData.polyProcessed(mm).Right.Time*ones(size(xdatright(mm,:))); 
        
        %April Tag Data
        AprilTagTime(mm) = MidCamData.AprilTag(mm).time;
        AprilTagX(mm) = MidCamData.AprilTag(mm).Location(1);
        AprilTagY(mm) = MidCamData.AprilTag(mm).Location(2);
end

%% Correcting Extraneous Data and Reformatting


smoothing1 = find(ydatleft <= 500);
smoothing2 = find(ydatright >= 675);
smoothing3 = find(ydatleft >= 675);


for ii = 1:1:length(smoothing1)
    ydatleft(smoothing1(ii)) = ydatleft(smoothing1(ii) - 1);
end

for ii = 1:1:length(smoothing2)
    ydatright(smoothing2(ii)) = ydatright(smoothing2(ii) - 1);
end

for ii = 1:1:length(smoothing3)
    ydatleft(smoothing3(ii)) = ydatleft(smoothing3(ii) - 1);
end


%% Plotting Y Position Over Time for every X Pixel Value

figure()
for i = 1:1:length(xdatleft)
    plot3(xdatleft(:,i), tvalleft(:,i), ydatleft(:,i))
    hold on
    plot3(xdatright(:,i), tvalright(:,i), ydatright(:,i))
end

xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')


%% Plotting Energy Density for Every Trial

figure()
surf(xdatleft, tvalleft, ydatleft)
hold on
surf(xdatright, tvalright, ydatright)
colorbar
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')
shading interp

%% Limiting Trials to Better See Output

figure()
surf(xdatleft(250:350,:),tvalleft(250:350,:),ydatleft(250:350,:))
hold on
surf(xdatright(250:350,:), tvalright(250:350,:), ydatright(250:350,:))
colorbar
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
title('Spatial Height of Wave for Certain X Pixels Over Whole Trial')
shading interp








    
