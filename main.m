close all;
clear, clc;
addpath('C:\Users\Mikanae\Google Drive (maskinne@ualberta.ca)\Pierre_=_ESDLab (FESS Student Projects)\Miles Skinner\Experimental Data\Tensile_Viscoelastic\Tensile tests')
% Test data
sg_files = {'SG_GF03_03'};
instron_files = {'Instron_GF03_03'};

str_strain_text = {'Exp 02-01', 'Reg 02', 'Exp 03-02', 'Reg 02', 'Exp 03-02', 'Reg 03', 'Ha 1999'};
gauge_text = {'SG-GF02', 'SG-03-02', 'SG-GF03-03'};
instron_text = {'Instron-GF02', 'Instron-GF03-02', 'Instron-GF03-03'};

% Sample parameters
d_inner = 25.4; % inner diameter of the specimen (mm)
d_outer_min = 26.4; % minimum outer diameter (mm)
d_outer_max = 27.4; % maximum outer diamete (mm)
d_outer_average = mean([d_outer_min d_outer_max]); % average outer diameter (mm)

sample_parameters.k = 2.15; % gauge factor (2.09 for GF01 and aluminum, 2.15 for GF02 and GF03)
sample_parameters.v = 0.3; % theoretical Poisson's ratio for fiberglass composite
sample_parameters.E = 68.9*10^3; % elastic modulus for AL6061 (MPa)
sample_parameters.gauge_length = 100; % gauge length of specimen (mm)
sample_parameters.gain_factor = 100; % voltage signal gain (174 for GF03 2, 200 for GF03 3, and 100 for GF02, GF01, and aluminum)

% Setting test parameters
test_parameters.unit_conversion = 25.4^2; % conversion factor from in^2 to mm^2
test_parameters.voltage_source = 5; % Wheatstone bridge source voltage (V)

sample_parameters.area = (pi * (d_outer_average^2 - d_inner^2)) / 4;

% Analyse data
for k = 1:length(sg_files)
  [gauge_exp_results, instron_exp_results, reg_exp_results] = analyse_stress_data(instron_files{k}, sg_files{k}, sample_parameters, test_parameters);
  gauge(k) = gauge_exp_results;
  instron(k) = instron_exp_results;
  reg(k) = reg_exp_results;
end

strain_ha = linspace(0, 1.6e-3, 100);
stress_ha = 8.27e3 * strain_ha; %8.27 is transverse E in Ha 1999


% Outputting results
fprintf('The slope of the regression (Young''s modulus) is %0.1f GPa\n',reg.slope*10^-3)
fprintf('The y-intercept of the regression is %0.2f MPa\n',reg.y_int)
fprintf('The R^2 value of the regression is %0.4f\n',reg.r2_value)

% Plotting

% Plotting stress-strain curves w/ regression
figure(1), hold on
for k = 1:length(gauge)
  plot(gauge(k).strain_rolling100,instron(k).stress,'-s','MarkerIndices',1:3000:length(instron(k).stress))
  plot(gauge(k).strain_rolling100,reg(k).line,'--')
end
plot(strain_ha, stress_ha)

title('Stress-Strain Plot')
xlabel('Strain [mm/mm]')
ylabel('Applied Stress [MPa]')
legend(str_strain_text, 'Location', 'northeast')
ymax1 = get(gca, 'YLim');
set(gca, 'Fontsize', 11, 'YLim', [0 ymax1(2)])
grid on

%% Time Plots
% Plotting gauge strain vs. time
figure(2), hold on
for k = 1:length(gauge)
  plot(gauge(k).time_modified, gauge(k).strain_rolling100,'-s','MarkerIndices',1:3000:length(gauge(k).strain_rolling100))
end

title('Gauge Strain-Time Plot')
xlabel('Time [s]')
ylabel('Strain [mm/mm]')
legend(gauge_text,'Location','southeast')
ymax2 = get(gca,'YLim');
set(gca,'Fontsize',11,'YLim',[0 ymax2(2)])
grid on

% Plotting Instron strain vs. time
figure(3), hold on
for k = 1:length(gauge)
  plot(instron(k).time,instron(k).strain,'-s','MarkerIndices',1:3000:length(instron(k).time))
end

title('Instron Strain-Time Plot')
xlabel('Time [s]')
ylabel('Strain (mm/mm)')
legend(instron_text,'Location','southeast')
ymax3 = get(gca,'YLim');
set(gca,'Fontsize',11,'YLim',[0 ymax3(2)])
grid on
