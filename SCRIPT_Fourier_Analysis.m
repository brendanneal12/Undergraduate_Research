%% Fourier Analysis

clear all
clc
%%

load('MVI_0098fourier.mat')

%%

for i = 1:1:length(fittingFouData.Fourier.Info)
    tval(i) = fittingFouData.Fourier.Info(i).Time;
    freqs(i) = fittingFouData.Fourier.Info(i).data.w;
end

%%
figure()
plot(tval, freqs, 'b*')
xlabel('Time (s)')
ylabel('Spatial Frequency (cycles/pixel)')
title('Dominant Fourier Frequency over Time')
%%
figure()
histogram(freqs)
xlabel('Frequencies (cycles/pixel)')
ylabel('Number of Appearances')
title('Frequency of Dominant Frequencies over a Trial')





