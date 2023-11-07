% Space-time Spectral Analysis test
clear; clc; close all;

lon = 360;    % degrees in longitude
time = 120;   % days

[llon,ttime]=meshgrid([1:lon],[1:time]);

k1 = 8; w1 = 1/10;
v1 = sin(2*pi*k1*(llon/360)-2*pi*w1*ttime);

k2 = 5; w2 = -1/30;
v2 = sin(2*pi*k2*(llon/360)-2*pi*w2*ttime);

k3 = 6; w3 = 1/5;
v3 = sin(2*pi*k3*(llon/360)-2*pi*w3*ttime);

v = v1 +v2 +v3 +0.5*rand(size(v1));
figure;
subplot(2,1,1);
contourf(llon,ttime,v,[0.25:0.25:1]);

%[East, West] = space_time_Hayashi(v',v');
[East, West] = space_time_fft2(v',v');
freq=[0:size(East,2)-1]/(size(East,2)-1)*0.5;
wavenum=[0:size(East,1)-1];
subplot(2,1,2);
plot_spec_tk_new(freq,wavenum,East',West',0.1);

% testing Parseval theorem
vv1=mean(mean(v.*v))

vv2= sum(sum(East(2:end,2:end))) +sum(sum(West(2:end,2:end-1)))   ...  %
    +0.5*sum(sum(East(2:end,1))) +0.5*sum(sum(West(2:end,1)))     ...  % frequency = 0
    +0.5*sum(sum(East(1,1:end))) +0.5*sum(sum(West(1,2:end-1)))        % wavenumber = 0
