% The raw temperature data must be in a csv file in the form
% m,d,y,h,m,s,chA,Heater,chB. No spaces or characters; only int values in
% the file.

clear
% addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\Experimental Data'...
%     '\Tensile Viscoelastic\VE']);
addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\Experimental Data'...
    '\Tensile Viscoelastic\VE']);

raw_data = csvread('prelim_temp03_clean.txt');
month = raw_data(:,1);
day = raw_data(:,2);
year = raw_data(:,3);
h = raw_data(:,4);
min = raw_data(:,5);
sec = raw_data(:,6);
chA = raw_data(:,7);
heat = raw_data(:,8);
chB = raw_data(:,9);

ind = find(h==12, 1, 'last');
h(ind+1:end) = h(ind+1:end) + 12;
t = datenum(year, month, day, h, min, sec);
out = t - t(1);
[~,mo,d,hr,mi,s] = datevec(out);
elapsed_time = duration(hr,mi,s, 'Format', 'm');

for k = 2:length(chA)
    dAdt(k) = chA(k-1) - chA(k);
    dBdt(k) = chB(k-1) - chB(k);
end
dAdt_mean = movmean(dAdt,12);
dBdt_mean = movmean(dBdt,12);
dur = minutes(elapsed_time);

% [fitresult, gof] = mean_bestfit(dur, dAdt_mean');
% x = linspace(1,dur(end),length(dur));
% y = fitresult.a .* exp(fitresult.b .* x) + fitresult.c .* exp(fitresult.d .* x);
% 
% ind = find(y >= -0.005, 1, 'first');

off_set = heat - chA;

figure(1), hold on
plot(elapsed_time,heat)
plot(elapsed_time,chA)
% plot(elapsed_time,chB)

xlabel('Duration [min]')
ylabel('Temperature [^oC]')
grid on
legend('Set Temp', 'Surface Temp', 'Location', 'Southeast')
set(gca, 'FontSize', 12)

figure(2), hold on
plot(elapsed_time(1:end),dAdt_mean)
% plot(elapsed_time(1:end),dBdt_mean)

xlabel('Duration [min]')
ylabel('d{T_s}/dt')
grid on
set(gca, 'FontSize', 12)

figure(3), hold on
plot(elapsed_time,off_set)
xlabel('Duration [min]')
ylabel('Set Temp - Surface Temp')
grid on
set(gca, 'FontSize', 12)
