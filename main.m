clear, close

addpath(['C:\Users\Mikanae\Google Drive (maskinne@ualberta.ca)\'...
  'Pierre_=_ESDLab (FESS Student Projects)\Miles Skinner\'...
  'Experimental Data\Tensile_Viscoelastic\Tensile tests\Data CSV'])

exp_name = {'GF05-02'};

%% ------------------------------------------------------------------------
%  ---- Load experimental data --------------------------------------------
%  ------------------------------------------------------------------------
fid = fopen('Exp_List.csv');
exp_list = textscan(fid, '%s%s%s%s%f%f%f%f%f%f%f%f%s', 'Delimiter', ',', 'Headerlines', 1);
fclose(fid);

fid = fopen('Sample_Data.csv');
samp_data = textscan(fid, '%s%f%f%f%f%f%f%f%f%f%f', 'Delimiter', ',', 'Headerlines', 1);
fclose(fid);

%% ------------------------------------------------------------------------
%  ---- Parse Data --------------------------------------------------------
%  ------------------------------------------------------------------------
exp_rows = find(strcmp(exp_name, exp_list{:,1}));
param_mat = cell2mat(exp_list(5:12));

instron_row = exp_rows(strcmp('Instron', exp_list{2}(exp_rows)));
instron_file = [exp_list{3}{instron_row}, '.csv'];
instron_data = csvread(instron_file, 2, 0); % starts at A3
instron_param = param_mat(instron_row,:);

sg_row = exp_rows(strcmp('SG', exp_list{2}(exp_rows)));
  % need if-then statement for separating half and quarter bridge conditions
rows = length(sg_row);

for k = 1:rows
  sg_file = [exp_list{3}{sg_row(k)}, '.csv'];
  sg_data(:,:,k) = csvread(sg_file, 10, 0); %starts at A11
  sg_param(k,:) = param_mat(sg_row(k),:); % param order is the column names in exp_list starting at C5.
    %Bridge_type, Direction, Gauge_length, Gauge_factor, Gain, Input_voltage,
    %Volume_fraction, Sample rate
end

samp_row = find(strcmp(exp_list{4}{exp_rows(1)},samp_data{1}(:)));
samp_mat = cell2mat(samp_data(2:11));
samp_param = samp_mat(samp_row,:);

%% ------------------------------------------------------------------------
%  ---- Begin Calculations ------------------------------------------------
%  ------------------------------------------------------------------------
try
  eff_area = calculate_effective_area(samp_param);
catch
  %geometric area when winding parameters not available
  eff_area = pi * (samp_param(2)^2 - samp_param(1)^2) / 4; % sample cross section area
end

for k = 1:rows
  % Process Instron and strain gauge data
  [results.in{k}, results.sg{k}] = process_data...
    (eff_area, sg_data(:,:,k), sg_param(k,:), instron_data, instron_param, samp_param);
  
  % Linear regression to find Young's modulus
  % intermediate array before calculating regression values
  intermediate = ([ones(length(results.sg{k}.strain),1),...
    results.sg{k}.strain]);
  % "\" operator on array for linear regression
  regress = intermediate \ results.in{k}.stress; 
  y_int(k) = regress(1); % [MPa]
  m(k) = regress(2); % slope a.k.a Young's modulus(MPa)
end

%% ------------------------------------------------------------------------
%  ---- Plotting and output -----------------------------------------------
%  ------------------------------------------------------------------------
figure(), hold on
for k = 1:rows
  plot(results.sg{k}.time, results.sg{k}.strain);
end
% plot(results.in{k}.time, results.in{k}.strain);
xlabel('time [s]'), ylabel('strain')
legend({'GF05-01-H', 'GF05-01-Q', 'instron'})

figure(), hold on
for k = 1:rows
  plot(results.sg{k}.strain, results.in{k}.stress)
end
% plot(results.in{k}.strain, results.in{k}.stress)
xlabel('strain'), ylabel('stress')
legend({'GF05-01-H', 'GF05-01-Q', 'Instron'}) 
