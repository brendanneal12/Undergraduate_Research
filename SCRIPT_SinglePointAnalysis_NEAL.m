%% Tracking of Single Points Over Time
%% Made my Brendan Neal

clear all
clc

%% Loading and Organizing Data

load('MVI_0098.mat')

for mm = 1:1:length(fittingPolyData.polyProcessed)
        ydat_point1(mm,:) = fittingPolyData.SinglePoint(mm).P1Data;
        ydat_point2(mm,:) = fittingPolyData.SinglePoint(mm).P2Data;
        tval(mm,:) = fittingPolyData.SinglePoint(mm).Time*ones(size(ydat_point1(mm,:)));
        
end

%% Performing Analysis
[Pt1_Pks, Pt1_Locs] = findpeaks(ydat_point1);
[Pt2_Pks, Pt2_Locs] = findpeaks(ydat_point2);



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
figure(1)
plot(tval,ydat_point1,'b')
hold on
plot(tval(Pt1_Locs),Pt1_Pks, 'y*')
hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 1 (Pixels)')
title('Behavior of specified Point 1 (X = 371.8) over Time')

%% Plotting Behavior of Point 2 over Time
figure(2)
plot(tval,ydat_point2,'r')
hold on
plot(tval(Pt2_Locs),Pt2_Pks, 'y*')
hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 2 (Pixels)')
title('Behavior of specified Point 2 (X = 1465.8) over Time')


%% Plotting Both on the Same Plot
figure(3)
plot(tval,ydat_point1)
hold on
plot(tval,ydat_point2)
hold off
xlabel('Time (s)')
ylabel('Spatial Height (Pixels)')
title('Behavior of both Specified Points over Time')
legend('X = 371.8','X = 1465.8', 'Location', 'southwest')

%% 3D Plot
x = [371.8 1465.8];

figure(4)
plot3(x(1)*ones(size(tval)), tval, ydat_point1)
hold on
plot3(x(2)*ones(size(tval)), tval, ydat_point2)
xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')





