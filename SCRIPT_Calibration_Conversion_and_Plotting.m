%% This Script will Convert Pixel Coordinates to World Coordinates

clear all
close all
clc

%% Loading Files
load('USCameraParams.mat')
load('UpStreamData.mat')

%% Extracting Intrinsic Parameters
K = UScameraParams.IntrinsicMatrix;
K = transpose(K);
K(1,3) = 0;
K(2,3) = 0;
KnownDistFromFrame = 3000; %mm

TimePerFrame = 1/30;

%% Performing Conversion

for i = 1:1:489 %Frame
    disp("Analyzing a New Frame")
    for jj = 1:1:1000 %Points
        WorldPoint = KnownDistFromFrame * inv(K) * UpStreamData.polyProcessed(i).points(:,jj);
        WorldPoint = WorldPoint(1:3);
        WorldPoints.polyProcessed(i).frame = i;
        WorldPoints.polyProcessed(i).Time = i*TimePerFrame;
        WorldPoints.polyProcessed(i).points(1:3,jj) = WorldPoint;
        
        disp("Analyzing Points")
     
    end
    
end

%% Pulling Data
for mm = 1:1:length(WorldPoints.polyProcessed)
        xdat(mm,:) = WorldPoints.polyProcessed(mm).points(1,:);
        ydat(mm,:) = WorldPoints.polyProcessed(mm).points(2,:);
        tval(mm,:) = WorldPoints.polyProcessed(mm).Time*ones(size(xdat(mm,:))); 
end

%% Plotting Y Position Over Time for every X Pixel Value
figure()
plot3(xdat(:,50), tval(:,50), ydat(:,50))
hold on
plot3(xdat(:,400), tval(:,400), ydat(:,400))
xlabel('Spatial X Position (mm)')
ylabel('Time (s)')
zlabel('Spatial Y Data (mm)')
legend('X = 51.667 mm', 'X = 420.72 mm')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')

%% Performing Analysis
[Pt1_Pks, Pt1_Locs] = findpeaks(ydat(:,50));
[Pt2_Pks, Pt2_Locs] = findpeaks(ydat(:,400));

jj1 = 1;
for ii = 2:1:length(Pt1_Pks)
    Period_Pt1(jj1) = tval(Pt1_Locs(jj1+1))-tval(Pt1_Locs(jj1));
    jj1 = jj1 + 1;
end

Wave_Period_1 = mean(Period_Pt1)

jj2 = 1;
for kk = 2:1:length(Pt2_Pks)
    Period_Pt2(jj2) = tval(Pt2_Locs(jj2+1))-tval(Pt2_Locs(jj2));
    jj2 = jj2 + 1;
end

Wave_Period_2 = mean(Period_Pt2)



%% Plotting Behavior of Point 1 over Time
figure()
plot(tval(:,50),ydat(:,50), 'b')
hold on
plot(tval(Pt1_Locs, 50),Pt1_Pks, 'y*')
plot(tval(:,50), mean(ydat(:,50))*ones(size(ydat(:,50))))
hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 1 (mm)')
title('Behavior of specified Point 1 (X = 51.667 mm) over Time')

%% Plotting Behavior of Point 2 over Time
figure()
plot(tval(:,50),ydat(:,400),'r')
hold on
plot(tval(Pt2_Locs,400),Pt2_Pks, 'y*')
plot(tval(:,400), mean(ydat(:,400))*ones(size(ydat(:,400))))
hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 2 (mm)')
title('Behavior of specified Point 2 (X = 420.721 mm ) over Time')


%% Plotting Both on the Same Plot
figure()
plot(tval(:,50),ydat(:,50))
hold on
plot(tval(:,50),ydat(:,400))
hold off
xlabel('Time (s)')
ylabel('Spatial Height (mm)')
title('Behavior of both Specified Points over Time')
legend('X = 51.668 mm','X = 420.721 mm', 'Location', 'southwest')

%% Plotting Y Position Over Time for every X Pixel Value

figure()
for i = 1:1:length(xdat)
    plot3(xdat(:,i), tval(:,i), ydat(:,i))
    hold on
end

xlabel('Spatial X Position (mm)')
ylabel('Time (s)')
zlabel('Spatial Y Data (mm)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')


%% Plotting Energy Density for Every Trial

figure()
surf(xdat, tval, ydat)
hold on
colorbar
xlabel('Spatial X Position (mm)')
ylabel('Time (s)')
zlabel('Spatial Y Data (mm)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')
shading interp

%% Limiting Trials to Better See Output

figure()
surf(xdat(250:350,:),tval(250:350,:),ydat(250:350,:))
colorbar

xlabel('Spatial X Position (mm)')
ylabel('Time (s)')
zlabel('Spatial Y Data (mm)')
title('Spatial Height of Wave for Certain X Pixels Over Whole Trial')
shading interp




%% Plotting Energy Density for Every Trial
figure()
surf(xdat, tval, ydat)
colorbar
xlabel('Spatial X Position (mm)')
ylabel('Time (s)')
zlabel('Spatial Y Data (mm)')
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')
shading interp







    
        
        
        
        
        
        
        
        
