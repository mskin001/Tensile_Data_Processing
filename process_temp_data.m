addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\Experimental Data'...
    '\Tensile Viscoelastic\VE']);
raw_data = csvread('prelim_temp01_clean.txt');
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
[y,mo,d,hr,mi,s] = datevec(out);
elapsed_time = duration(hr,mi,s, 'Format', 'm');

for k = 2:length(chA)
    dAdt(k) = chA(k-1) - chA(k);
    dBdt(k) = chB(k-1) - chB(k);
end

hold on
plot(elapsed_time,heat)
plot(elapsed_time,chA)
plot(elapsed_time,chB)

xlabel('Duration [min]')
ylabel('Temperature [^oC]')
legend('Heater', 'Specimen Outside', 'Specimen Inside', 'Location', 'Southeast')

figure(2), hold on
plot(elapsed_time(1:end),dAdt)
plot(elapsed_time(1:end),dBdt)

xlabel('Duration [min]')
ylabel('Temperature change [T_2 - T_1]')