%% Digital Wavelet Signal Processing - Project
% Professor: Dr. H. Amindavar
% Author: Arshia Samoudi
% E-mail: arshia-s79@aut.ac.ir
% University: Amirkabir University of Technology

%% Clear recent data
clear; close all; clc;

%% Load Data

data = load("O3Cons.mat");
O3 = data.O3;
O3_time = data.O3_time;

% Plotting
figure();
plot(O3_time , O3);
title("O3 Concentration");
ylabel("Cons"); xlabel("Time Duration");

%% HDWT

% N = length(O3);
N = 2^8;
x = O3(1:N);
t = O3_time(1:N);

wname = 'db1';
lvl = 4;

[c,l] = wavedec(x,lvl,'db1');
approx = appcoef(c,l,'db1');
for i = 1:lvl
    cd{i} = detcoef(c,l,i);
end

% Plotting

figure();
subplot(lvl+2,1,1);
plot(t,x);
title("Original Signal");

subplot(lvl+2,1,2);
plot(approx);
title("Approximation");

for i = 1:length(cd)
    subplot(lvl+2,1,i+2);
    plot(cd{i});
    title(['Detail Coefficiet - lvl: ' , num2str(i)]);
end

%% ARIMA MODEL Configuration

% ACF: AutoCorrelation Coefficient Function

figure();
autocorr(approx);
title("Sample Autocorrelation Function - Approximation");


for i = 1:length(cd)
    figure();
    autocorr(cd{i});
    title(["Sample Autocorrelation Function - Detail - lvl: " + num2str(i)])
end

% PACF: Partial AutoCorrelation Coefficient Function

figure();
parcorr(approx);
title("Sample Partial Autocorrelation Function - Approximation");


for i = 1:length(cd)
    figure();
    parcorr(cd{i});
    title(["Sample Partial Autocorrelation Function - Detail - lvl: " + num2str(i)])
end

%% APProximation

AP = length(approx)/2;
Mdl = arima(2,1,2);
EstMdl = estimate(Mdl,approx);
[APPHAT,APPHAT_MSE] = forecast(EstMdl,AP,approx);

app_hat = [approx ; APPHAT];


%% Detail

arima_detail = [arima(4,0,3) , arima(5,0,5) , arima(5,1,3) , arima(3,1,2)];

for i = 1:lvl
    AP = length(cd{i})/2;
    EstMdl = estimate(arima_detail(i),cd{i});
    [YF,YMSE] = forecast(EstMdl,AP,cd{i});
    cd_hat{i} = [cd{i} ; YF];
end


%% WaveLet Reconstruction with new C and L

c_new = app_hat;
l_new = length(app_hat);

for i = lvl:-1:1
    c_new = [c_new ; cd_hat{i}];
    l_new = [l_new ; length(cd_hat{i})];
end

l_new = [l_new ; 2 * l_new(end)];

x_pre = waverec(c_new , l_new , wname);



M = length(x_pre);

x1 = O3(N:M);
t1 = O3_time(N:M);

% 
figure();
plot(t1 , x1); hold on;
plot(t1 , x_pre(N:M))









