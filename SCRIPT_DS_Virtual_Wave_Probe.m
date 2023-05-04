%% This Script Picks 2 "Virtual Wave Probes" Over Time

%% Setup
clear all
clc
%%

load('DownStreamData.mat')


TimePerFrame = 1/30;

%% extract data
for mm = 1:1:length(DownStreamData.polyProcessed)
        xdat(mm,:) = DownStreamData.polyProcessed(mm).points(1,:);
        ydat(mm,:) = DownStreamData.polyProcessed(mm).points(2,:);
        tval(mm,:) = DownStreamData.polyProcessed(mm).Time*ones(size(xdat(mm,:))); 
end

%% Plotting Y Position Over Time for every X Pixel Value


figure()
plot3(xdat(:,50), tval(:,50), ydat(:,50))
hold on
plot3(xdat(:,400), tval(:,400), ydat(:,400))
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
legend('X = 103.0', 'X = 838.74')
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
hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 1 (Pixels)')
title('Behavior of specified Point 1 (X = 103.0) over Time')

%% Plotting Behavior of Point 2 over Time
figure()
plot(tval(:,50),ydat(:,400),'r')
hold on
plot(tval(Pt2_Locs,400),Pt2_Pks, 'y*')
hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 2 (Pixels)')
title('Behavior of specified Point 2 (X =838.74 ) over Time')


%% Plotting Both on the Same Plot
figure()
plot(tval(:,50),ydat(:,50))
hold on
plot(tval(:,50),ydat(:,400))
hold off
xlabel('Time (s)')
ylabel('Spatial Height (Pixels)')
title('Behavior of both Specified Points over Time')
legend('X = 103','X = 838.74', 'Location', 'southwest')
