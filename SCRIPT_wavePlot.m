%% SCRIPT_wavePlot.m makes a 3D plot showing the evolution of the free 
% surface over the course of an experiment

clear all
clc

load('MVI_0098.mat')



% extract data

for mm = 1:1:length(fittingPolyData.polyProcessed)
        xdat(mm,:) = fittingPolyData.polyProcessed(mm).points(1,:);
        ydat(mm,:) = fittingPolyData.polyProcessed(mm).points(2,:);
        tval(mm,:) = fittingPolyData.polyProcessed(mm).Time*ones(size(xdat(mm,:)));
end

skp = 10;
% plot 3d graph with time along the y axis
figure(1); clf
plot3(xdat(1:skp:end,:)',tval(1:skp:end,:)',ydat(1:skp:end,:)'); % not an efficient way to do this.....
view(3)
set(gca,'DataAspectRatio',[30 1 3])
axis([0 max(max(xdat)) 0 max(max(tval)) min(min(ydat)) max(max(ydat))])
xlabel('X-position (pixels)')
ylabel('Time (sec)')
zlabel('Wave Amplitude (pixels)')


% plot 2D graph with all snapshots
figure(2); clf
plot(xdat',ydat')
hold on
xline(999.1661, 'r*')
xline(1176.9006,'b*')
xline(821.4361,'b*')
hold off
axis([0 max(max(xdat)) 0 max(max(ydat))+20])
xlabel('X-position (pixels)')
ylabel('Wave Amplitude (pixels)')

