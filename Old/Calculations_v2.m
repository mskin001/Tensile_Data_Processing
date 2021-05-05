%% Preliminary code (always execute before running other sections)
close all;
clear, clc;

% Instron test data
instron_data = xlsread('Strain Gaugue On Al Sample');
gauge_data = xlsread('AL01-SG001.xlsx');

instron_time = instron_data(:,1);
instron_extension = instron_data(:,2);
instron_load = instron_data(:,3);

% Gauge data with end values excluded to match vector size of Instron data
% for plotting purposes 
gauge_time = gauge_data(12:length(instron_time)+11,1);
gauge_voltage = gauge_data(12:length(instron_extension)+11,2);

% Setting test parameters
k = 2.09; % gauge factor
v = 0.33; % Poisson's ratio for AL6061
E = 68.9*10^3; % elastic modulus for AL6061 (MPa)
d = 0.375; % diameter of specimen (in)
unit_conversion = 25.4^2; % conversion factor from in^2 to mm^2
voltage_source = 5; % Wheatstone bridge source voltage (V)
gauge_length = 25.4; % gauge length of specimen (mm)
gain_factor = 100; % voltage signal gain

% Calculating area, Instron strain & strain, and theoretical(reference) 
% stress-strain curve
area = (pi/4)*d^2*unit_conversion; % mm^2
stress_instron = instron_load/area; % MPa
strain_instron = instron_extension/gauge_length; % mm/mm
strain_theoretical = stress_instron/E; % mm/mm

% Instron extension/strain not yet plotted in the following sections as the
% data is inaccurate and would throw off the scale of the graph, making the
% other data harder to interpret

%% Strain from zeroing out voltage
% Subtracting initial voltage value (unstrained) from array, inverting
% sign, and dividing by gain factor
voltage_zeroed = -(gauge_voltage - gauge_voltage(1))/gain_factor;

% Calculating strain from given equation
gauge_strain_zeroed = (1/(1+v))*(4/k)*(voltage_zeroed/voltage_source);

% Plotting
figure(1)
hold on
plot(strain_theoretical, stress_instron,'-sb','MarkerIndices',1:1000:length(stress_instron),'MarkerFaceColor','b')
plot(gauge_strain_zeroed, stress_instron,'-k')
title('AL6061 Stress-Strain (Zeroed Voltage Method)')
xlabel('Strain [mm/mm]') 
ylabel('Applied Stress [MPa]')
legend('Expected','Strain Gauge','Location','southeast')
set(gca,'Fontsize',11)
grid on

%% Strain from subtracting average initial voltage values
% Subtracting average initial voltage from array, inverting sign,and
% dividing by gain factor. Number of elements used in averaging was 
% somewhat arbitrary (eyeballed for "noise" in data file).
voltage_average = -(gauge_voltage - mean(gauge_voltage(1:77)))/gain_factor;

% Calculating strain from given equation
gauge_strain_average = (1/(1+v))*(4/k)*(voltage_average/voltage_source);

% Plotting
figure(2)
plot(strain_theoretical, stress_instron,'-sb','MarkerIndices',1:1000:length(stress_instron),'MarkerFaceColor','b')
hold on
plot(gauge_strain_average, stress_instron,'-k')
title('AL6061 Stress-Strain (Average Initial Voltage Method)')
xlabel('Strain [mm/mm]') 
ylabel('Applied Stress [MPa]')
legend('Expected','Strain Gauge','Location','southeast')
set(gca,'Fontsize',11,'XLim',[0 1.0000e-03])
grid on

%% Strain from rolling average voltage 
% Subtracting initial voltage value (unstrained) from array, inverting
% sign, and dividing by gain factor
voltage_zeroed = -(gauge_voltage - gauge_voltage(1))/gain_factor;

% Applying rolling averages to smoothen out noise with different 
% averaging windows

voltage_rolling_3 = movmean(voltage_zeroed,3); % window = 3
voltage_rolling_10 = movmean(voltage_zeroed,10); % window = 10
voltage_rolling_25 = movmean(voltage_zeroed,25); % window = 25
voltage_rolling_50 = movmean(voltage_zeroed,50); % window = 50
voltage_rolling_100 = movmean(voltage_zeroed,100); % window = 100

% Calculating strain from given equation
gauge_strain_rolling_3 = (1/(1+v))*(4/k)*(voltage_rolling_3/voltage_source);
gauge_strain_rolling_10 = (1/(1+v))*(4/k)*(voltage_rolling_10/voltage_source);
gauge_strain_rolling_25 = (1/(1+v))*(4/k)*(voltage_rolling_25/voltage_source);
gauge_strain_rolling_50 = (1/(1+v))*(4/k)*(voltage_rolling_50/voltage_source);
gauge_strain_rolling_100 = (1/(1+v))*(4/k)*(voltage_rolling_100/voltage_source);

% Plotting
figure(3)
plot(strain_theoretical, stress_instron,'-sb','MarkerIndices',1:1000:length(stress_instron),'MarkerFaceColor','b')
hold on
plot(gauge_strain_rolling_3, stress_instron,'-k')
plot(gauge_strain_rolling_10, stress_instron,'-r')
plot(gauge_strain_rolling_25, stress_instron,'-g')
plot(gauge_strain_rolling_50, stress_instron,'-','Color',[0.8500 0.3250 0.0980])
plot(gauge_strain_rolling_100, stress_instron,'-','Color',[0.4940 0.1840 0.5560])
title('AL6061 Stress-Strain (Rolling Average Voltage Method)')
xlabel('Strain [mm/mm]') 
ylabel('Applied Stress [MPa]')
legend('Expected','Strain Gauge (w = 3)','Strain Gauge (w = 10)','Strain Gauge (w = 25)','Strain Gauge (w = 50)','Strain Gauge (w = 100)','Location','southeast')
set(gca,'Fontsize',11)
grid on

% Note: The effects of the different rolling average windows can be seen
% more clearly by creating one strain gauge curve at a time by commenting
% out the rest of the plots

%% Time Plots
% Subtracting initial voltage value (unstrained) from array, inverting
% sign, and dividing by gain factor. Using entire time and voltage arrays
% for these plots, unlike stress-strain plots.
gauge_time_modified = gauge_data(12:end,1);
gauge_voltage_modified = gauge_data(12:end,2);
voltage_zeroed_modified = -(gauge_voltage_modified - gauge_voltage_modified(1))/gain_factor;

% Calculating strain from given equation
gauge_strain_zeroed_modified = (1/(1+v))*(4/k)*(voltage_zeroed_modified/voltage_source);

% Plotting strain vs. time
figure(4)
plot(instron_time, strain_theoretical,'-sb','MarkerIndices',1:2000:length(strain_theoretical),'MarkerFaceColor','b')
hold on
% plot(instron_time, strain_instron,'-sk','MarkerIndices',1:2000:length(strain_instron),'MarkerFaceColor','k')
plot(gauge_time_modified, gauge_strain_zeroed_modified,'-s','MarkerIndices',1:2000:length(gauge_strain_zeroed),'Color',[0.8500 0.3250 0.0980],'MarkerFaceColor',[0.8500 0.3250 0.0980])
title('AL6061 Strain-Time Plot')
xlabel('Time [s]') 
ylabel('Strain [mm/mm]')
legend('Expected','Instron Data','Strain Gauge Data','Location','east')
set(gca,'Fontsize',11,'YLim',[0 0.0350])
grid on