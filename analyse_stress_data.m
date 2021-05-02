function [gauge, instron, reg] = analyse_stress_data(instron_file, sg_file, sample_parameters, test_parameters)
% Instron data
instron_data = csvread(instron_file, 2, 0);
% start_instron = 3; % row at which instron data numerical values begin in Excel sheet (may vary between data sets)
instron_time = instron_data(:,1);
instron_extension = instron_data(:,2);
instron_load = instron_data(:,3);

% Gauge data
gauge_data = csvread(sg_file, 10, 0);
% start_gauge = 11; % row at which gauge data numerical values begin in Excel sheet (may vary between data sets)
gauge_time = gauge_data(:,1);
gauge_voltage = gauge_data(:,2);

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
voltage_zeroed = abs((gauge_voltage - gauge_voltage(1)) / sample_parameters.gain_factor);

% Truncating beginning and end of gauge data with threshold voltage to
% approximately coincide gauge data with the Instron test data
counter = false;
beginning_truncation = 500; % specifying beginning truncation window for following while loop (can change if there's irregularities near the begining)
i = 0;
while counter == false
    i = i+1;
    if voltage_zeroed(i) > max(voltage_zeroed(1:beginning_truncation))
        counter = true;
        voltage_zeroed_modified = voltage_zeroed(i:length(instron_stress)+i-1);
        gauge_time_modified = gauge_time(i:length(instron_stress)+i-1)-gauge_time(i);
    end
end

% Truncating end of the data to remove data near/at break point of the
% sample
threshold_voltage_end = max(voltage_zeroed_modified) - 0.0005; % specifying threshold voltage to find cut off point (can change if there's irregularities near the end)
j = length(voltage_zeroed_modified);
while voltage_zeroed_modified(j) < threshold_voltage_end
    j = j-1;
    if voltage_zeroed_modified(j) > threshold_voltage_end
        voltage_zeroed_modified = voltage_zeroed_modified(1:j);
        instron_stress = instron_stress(1:j);
        gauge_time_modified = gauge_time_modified(1:j);
        instron_extension = instron_extension(1:j);
        instron_time = instron_time(1:j);
    end
end

instron_strain = instron_extension / sample_parameters.gauge_length;

% Applying rolling average to smoothen out noise w/ averaging window of
% 100
voltage_zeroed_rolling_100 = movmean(voltage_zeroed_modified,100);

% Calculating strain from given equation
gauge_strain_rolling_100 = (1 / (1+sample_parameters.v))*(4 / sample_parameters.k)...
    * (voltage_zeroed_rolling_100 / test_parameters.voltage_source);


%  Calculating Young's Modulus w/ linear regression
regression_intermediate = ([ones(length(gauge_strain_rolling_100),1), gauge_strain_rolling_100]); % creating intermediate array before calculating regression values
regression_array_results = regression_intermediate \ instron_stress; % using \ operator on array for linear regression
regression_y_intercept = regression_array_results(1); % regression y-intercept (MPa)
regression_slope = regression_array_results(2); % regression slope a.k.a Young's modulus(MPa)

% Calculating R^2 value of regression
R2_line = regression_intermediate * regression_array_results; % intermediate value used in R^2 formula (represents calculated y values from regression)
R2_value = 1 - sum((instron_stress - R2_line).^2) / sum((instron_stress - mean(instron_stress)).^2); % R^2 value using standard formula

% Allocating results
gauge.strain_rolling100 = gauge_strain_rolling_100;
gauge.time_modified = gauge_time_modified;

instron.stress = instron_stress;
instron.strain = instron_strain;
instron.time = instron_time;

reg.line = R2_line;
reg.r2_value = R2_value;
reg.y_int = regression_y_intercept;
reg.slope = regression_slope;
