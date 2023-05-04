%% Misc. Testing

clc
clear all

%% Loading and Organizing Data

load('MVI_0098.mat')

%% Testing

Coeffs = fittingPolyData.polynomial.Coeffs(61).data;
Data = fittingPolyData.polyProcessed(61).points;

% manually calculate by finding first and second derivative
Pdot = [5*Coeffs(1) 4*Coeffs(2) 3*Coeffs(3) 2*Coeffs(4) Coeffs(5)];
Pdotdot = [4*Pdot(1) 3*Pdot(2) 2*Pdot(3) Pdot(4)];
%roots command solve for 0
Peak_X = roots(Pdot);
Peak_Direction = roots(Pdotdot);
%knnsearch find closest values

%index from there

