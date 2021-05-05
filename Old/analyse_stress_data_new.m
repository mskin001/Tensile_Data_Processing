function [gauge, instron, reg] = analyse_stress_data_new(instron_file, sg_file, sample_parameters, test_parameters)
sample_rate = 100; %Hz

% Gauge data
gauge_data = xlsread(sg_file);
start_gauge = 11; % row at which gauge data numerical values begin in Excel sheet (may vary between data sets)
gauge_time = gauge_data(start_gauge:end,1);
gauge_voltage = gauge_data(start_gauge:end,2);

% Instron data
try
  instron_data = xlsread(instron_file);
  start_instron = 16; % row at which instron data numerical values begin in Excel sheet (may vary between data sets)
  instron_time = instron_data(start_instron:end,1);
  instron_extension = instron_data(start_instron:end,2);
  instron_load = instron_data(start_instron:end,3);
catch
  instron_time = 0:0.1:gauge_time(end);
  instron_load = linspace(0,1500,length(gauge_time));
  instron_extension = linspace(0,0.4,length(gauge_time));
  warning('Instron data no available for %s', sg_file)
end



% Preallocation
gauge = struct('strain_rolling100', [], 'time_modified', []);
instron = struct('stress', [], 'strain', [], 'time', []);
reg = struct('line', [], 'r2_value', [], 'y_int', [], 'slope', []);

% Calculating area, Instron stress & strain, and theoretical(reference)
% stress-strain curve
instron_stress = instron_load/sample_parameters.area; % MPa
strain_theoretical = instron_stress / sample_parameters.E; % mm/mm

%% Strain from rolling average voltage
% Subtracting initial voltage value (unstrained) from array, taking,
% absolute value, and dividing by gain factor
temp = reshape(gauge_voltage,sample_rate,length(gauge_voltage)/sample_rate);
gv_avg = sum(temp,1)/sample_rate;
gv_zeroed = gv_avg - gv_avg(1); %shift gauge volatage values to start at zero
ind = find(~gv_zeroed);
gv_zeroed(1:ind(end)) = [];

gt = gauge_time(1:sample_rate:end);
gt_zeroed = gt(ind(end)+1:end);

if mod(length(instron_load),sample_rate) ~= 0
  instron_load(1:mod(length(instron_load),sample_rate)) = [];
end
temp = reshape(instron_load, sample_rate,length(instron_load)/sample_rate);
inst_avg = sum(temp,1) / sample_rate;
% inst_zeroed = avg(ind(end)-1:end);


instron_strain = instron_extension / sample_parameters.gauge_length;

% Applying rolling average to smoothen out noise w/ averaging window of
% 100
% voltage_zeroed_rolling_100 = movmean(voltage_zeroed_modified,100);

% Calculating strain from given equation
gauge_strain = (1 / (1+sample_parameters.v))*(4 / sample_parameters.k)...
    * (gv_zeroed / test_parameters.voltage_source);


%  Calculating Young's Modulus w/ linear regression
regression_intermediate = ([ones(length(gauge_strain),1), gauge_strain]); % creating intermediate array before calculating regression values
regression_array_results = regression_intermediate \ instron_stress; % using \ operator on array for linear regression
regression_y_intercept = regression_array_results(1); % regression y-intercept (MPa)
regression_slope = regression_array_results(2); % regression slope a.k.a Young's modulus(MPa)

% Calculating R^2 value of regression
R2_line = regression_intermediate * regression_array_results; % intermediate value used in R^2 formula (represents calculated y values from regression)
R2_value = 1 - sum((instron_stress - R2_line).^2) / sum((instron_stress - mean(instron_stress)).^2); % R^2 value using standard formula

% Allocating results
gauge.strain_rolling100 = gauge_strain;
gauge.time_modified = gauge_time_modified;

instron.stress = instron_stress;
instron.strain = instron_strain;
instron.time = instron_time;

reg.line = R2_line;
reg.r2_value = R2_value;
reg.y_int = regression_y_intercept;
reg.slope = regression_slope;