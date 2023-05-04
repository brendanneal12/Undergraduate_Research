%% This Script will Convert Pixel Coordinates to World Coordinates

clear all
close all
clc

%% Loading Files
load('MIDCameraParams.mat')
load('MidCamData.mat')

%% Ground Truth
[TimeGT, WaveProbe, Sting] = readvars('Run_544_Sting_Data.xlsx');

%% Extracting Intrinsic Parameters
K = MIDcameraParams.IntrinsicMatrix;
K = transpose(K);
K(1,3) = 0;
K(2,3) = 0;
KnownDistFromFrame = 2900; %mm

TimePerFrame = 1/30;

%% Performing Conversion

for i = 1:1:489 %Frame
    disp("Analyzing a New Frame")
    for jj = 1:1:1000 %Points
        WorldPointLeft = KnownDistFromFrame * inv(K) * MidCamData.polyProcessed(i).Left.points(:,jj);
        WorldPointLeft = WorldPointLeft(1:3);
        WorldPoints.polyProcessed(i).Left.frame = i;
        WorldPoints.polyProcessed(i).Left.Time = i*TimePerFrame;
        WorldPoints.polyProcessed(i).Left.points(1:3,jj) = WorldPointLeft;
        
        WorldPointRight = KnownDistFromFrame * inv(K) * MidCamData.polyProcessed(i).Right.points(:,jj);
        WorldPointRight = WorldPointRight(1:3);
        WorldPoints.polyProcessed(i).Right.frame = i;
        WorldPoints.polyProcessed(i).Right.Time = i*TimePerFrame;
        WorldPoints.polyProcessed(i).Right.points(1:3,jj) = WorldPointRight;
        
        WorldPointAprilTag = KnownDistFromFrame * inv(K) * transpose([MidCamData.AprilTag(i).Location,1]);
        WorldPointAprilTag = WorldPointAprilTag(1:3);
        WorldPoints.AprilTag(i).frame = i;
        WorldPoints.AprilTag(i).Time = i*TimePerFrame;
        WorldPoints.AprilTag(i).Location = WorldPointAprilTag;
        
        
        
        disp("Analyzing Points")
     
    end
    
end

%% Pulling Data

for mm = 1:1:length(WorldPoints.polyProcessed)
        xdatleft(mm,:) = WorldPoints.polyProcessed(mm).Left.points(1,:);
        ydatleft(mm,:) = WorldPoints.polyProcessed(mm).Left.points(2,:);
        tvalleft(mm,:) = WorldPoints.polyProcessed(mm).Left.Time*ones(size(xdatleft(mm,:)));
        
        xdatright(mm,:) = WorldPoints.polyProcessed(mm).Right.points(1,:);
        ydatright(mm,:) = WorldPoints.polyProcessed(mm).Right.points(2,:);
        tvalright(mm,:) = WorldPoints.polyProcessed(mm).Right.Time*ones(size(xdatright(mm,:))); 
        
        %April Tag Data
        AprilTagTime(mm) = WorldPoints.AprilTag(mm).Time;
        AprilTagX(mm) = WorldPoints.AprilTag(mm).Location(1);
        AprilTagY(mm) = WorldPoints.AprilTag(mm).Location(2);
end

%% Smoothing Data
smoothing1 = find(ydatleft <= 250);
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

%% Ground Truth
TimeGT = TimeGT - TimeGT(1);
WaveProbe = WaveProbe*100;
Sting = Sting * 100;
WaveProbe = WaveProbe + mean(ydatleft(:,400));
Sting = Sting + + mean(AprilTagY(:,400));

%% Plotting Behavior of Point 1 over Time - Upstream
figure()
plot(tvalleft(:,400),ydatleft(:,400), 'b')
hold on
plot(tvalleft(:,400), mean(ydatleft(:,400))*ones(size(ydatleft(:,400))))
plot(TimeGT, WaveProbe)
hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 1 (mm)')
title('Comparison of Virtual Wave Probe with Closest Physical Wave Probe')
set(gca,'YDir','reverse')

%% Plotting Behavior of Point 2 over Time - DownStream
figure()
plot(tvalright(:,50),ydatright(:,50),'r')
hold on
plot(tvalright(:,50), mean(ydatright(:,50))*ones(size(ydatright(:,50))))
hold off
xlabel('Time (s)')
ylabel('Spatial Height of Point 2 (mm)')
title('Behavior of specified Downstream Probe (X = 1831.9 ) over Time')
set(gca,'YDir','reverse')


%% Plotting Both on the Same Plot
figure()
plot(tvalleft(:,400),ydatleft(:,400))
hold on
plot(tvalright(:,50),ydatright(:,50))
hold off
xlabel('Time (s)')
ylabel('Spatial Height (mm)')
title('Behavior of both Specified Points over Time')
legend('Upstream Probe','Downstream Probe', 'Location', 'southeast')
set(gca,'YDir','reverse')

%% Plotting April Tag Behavior
figure()
plot(AprilTagTime,AprilTagY)
hold on
plot(TimeGT, Sting)
hold off
xlabel('Time (s)')
ylabel('Spatial Height (mm)')
title('AprilTag Height vs Time')
set(gca,'YDir','reverse')


figure()
plot(AprilTagX,AprilTagY)
hold off
xlabel('Spatial Surge (mm)')
ylabel('Spatial Heave (mm)')
title('AprilTag Heave vs Surge')
set(gca,'YDir','reverse')











    
        
        
        
        
        
        
        
        
