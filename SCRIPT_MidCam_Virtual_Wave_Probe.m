%% This Script Picks 2 "Virtual Wave Probes" Over Time

%% Setup
clear all
clc
%%

%% NEED SOME SMOOTHING!!!! %%

load('MidCamData.mat')


TimePerFrame = 1/30;

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

%% Smoothing Data
smoothing1 = find(ydatleft <= 475);
smoothing2 = find(isnan(AprilTagX));
smoothing3 = find(isnan(AprilTagY));

for ii = 1:1:length(smoothing1)
    ydatleft(smoothing1(ii)) = ydatleft(smoothing1(ii) - 1);
end

for ii = 1:1:length(smoothing2)
    AprilTagX(smoothing2(ii)) = (AprilTagX(smoothing2(ii) - 1) + AprilTagX(smoothing2(ii) + 1))/2;
end

for ii = 1:1:length(smoothing3)
    AprilTagY(smoothing3(ii)) = (AprilTagY(smoothing3(ii) - 1) + AprilTagY(smoothing3(ii) + 1))/2;
end



%% Plotting Y Position Over Time for every X Pixel Value

figure()
plot3(xdatleft(:,50), tvalleft(:,50), ydatleft(:,50))
hold on
plot3(xdatleft(:,400), tvalleft(:,400), ydatleft(:,400))

plot3(xdatright(:,50), tvalright(:,50), ydatright(:,50))

plot3(xdatright(:,400), tvalright(:,400), ydatright(:,400))

xlabel('Spatial X Position (Pixels)')
ylabel('Time (s)')
zlabel('Spatial Y Data (Pixels)')
legend('X = 51.35', 'X = 382.43', "X = 1831.9 ", "X =2059.6")
title('Spatial Height of Wave for Every X Pixel Over Whole Trial')

%% Performing Analysis
[Pt1_Pks, Pt1_Locs] = findpeaks(ydatleft(:,400));
[Pt2_Pks, Pt2_Locs] = findpeaks(ydatright(:,50));



jj1 = 1;
for ii = 2:1:length(Pt1_Pks)
    Period_Pt1(jj1) = tvalleft(Pt1_Locs(jj1+1))-tvalleft(Pt1_Locs(jj1));
    jj1 = jj1 + 1;
end

Wave_Period_1 = mean(Period_Pt1)

jj2 = 1;
for kk = 2:1:length(Pt2_Pks)
    Period_Pt2(jj2) = tvalright(Pt2_Locs(jj2+1))-tvalright(Pt2_Locs(jj2));
    jj2 = jj2 + 1;
end

Wave_Period_2 = mean(Period_Pt2)

%% Plotting Behavior of Point 1 over Time - Upstream
figure()
plot(tvalleft(:,400),ydatleft(:,400), 'b')
% hold on
% plot(tvalleft(Pt1_Locs, 400),Pt1_Pks, 'y*')
% hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 1 (Pixels)')
title('Behavior of specified Upstream Probe (X = 382.43) over Time')
set(gca,'YDir','reverse')

%% Plotting Behavior of Point 2 over Time - DownStream
figure()
plot(tvalleft(:,50),ydatleft(:,50),'r')
% hold on
% plot(tvalleft(Pt2_Locs,50),Pt2_Pks, 'y*')
% hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 2 (Pixels)')
title('Behavior of specified Downstream Probe (X = 1831.9 ) over Time')
set(gca,'YDir','reverse')


%% Plotting Both on the Same Plot
figure()
plot(tvalleft(:,400),ydatleft(:,400))
hold on
plot(tvalright(:,50),ydatright(:,50))
hold off
xlabel('Time (s)')
ylabel('Spatial Height (Pixels)')
title('Behavior of both Specified Points over Time')
legend('Downstream Probe','Upstream Probe', 'Location', 'southeast')
set(gca,'YDir','reverse')

%% Plotting April Tag Behavior
figure()
plot(AprilTagTime,AprilTagY)
hold off
xlabel('Time (s)')
ylabel('Spatial Height (Pixels)')
title('AprilTag Height vs Time')
set(gca,'YDir','reverse')


figure()
plot(AprilTagX,AprilTagY)
hold off
xlabel('Spatial Surge (Pixels)')
ylabel('Spatial Heave (Pixels)')
title('AprilTag Heave vs Surge')
set(gca,'YDir','reverse')

