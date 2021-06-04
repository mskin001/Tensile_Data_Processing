clear, close all

addpath(['C:\Users\Mikanae\Google Drive (maskinne@ualberta.ca)\'...
  'Pierre_=_ESDLab (FESS Student Projects)\Miles Skinner\'...
  'Experimental Data\Tensile_Viscoelastic\Tensile tests\Data CSV'])

exp_name = {'GF05-01', 'GF05-02', 'GF05-03'};
legText = {'H-05-01', 'Q-05-01', 'H-05-02', 'Q-05-02', 'H-05-02'};
b = 0; % indexing variable
while ~isempty(exp_name)
  %% ------------------------------------------------------------------------
  %  ---- Load experimental data --------------------------------------------
  %  ------------------------------------------------------------------------
  fid = fopen('Exp_List.csv');
  exp_list = textscan(fid, '%s%s%s%s%f%f%f%f%f%f%f%f%s%s', 'Delimiter', ',', 'Headerlines', 1);
  fclose(fid);

  fid = fopen('Sample_Data.csv');
  samp_data = textscan(fid, '%s%f%f%f%f%f%f%f%f%f%f', 'Delimiter', ',', 'Headerlines', 1);
  fclose(fid);

  %% ------------------------------------------------------------------------
  %  ---- Parse Data --------------------------------------------------------
  %  ------------------------------------------------------------------------
  cur_exp = exp_name{1};
  exp_rows = find(strcmp(cur_exp, exp_list{:,1}));
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
    sg_data{k+b} = csvread(sg_file, 10, 0); %starts at A11
    sg_param{k+b} = param_mat(sg_row(k),:); % param order is the column names in exp_list starting at C5.
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
    [results.in{k+b}, results.sg{k+b}] = process_data...
      (eff_area, sg_data{k+b}, sg_param{k+b}, instron_data, instron_param, samp_param);

    % Linear regression to find Young's modulus
    % intermediate array before calculating regression values
    intermediate = ([ones(length(results.sg{k+b}.strain),1),...
      results.sg{k+b}.strain]);
    % "\" operator on array for linear regression
    regress = intermediate \ results.in{k+b}.stress;
    y_int(k+b) = regress(1); % [MPa]
    m(k+b) = regress(2); % slope a.k.a Young's modulus(MPa)
  end
 b = b + rows;
 exp_name(1) = [];

end

%% ------------------------------------------------------------------------
%  ---- Plotting and output -----------------------------------------------
%  ------------------------------------------------------------------------
figure(), hold on
for k = 1:b
  plot(results.sg{k}.time, results.sg{k}.strain*100);
end
% plot(results.in{k}.time, results.in{k}.strain);
xlabel('time [s]'), ylabel('% strain')
legend(legText, 'Location', 'NorthWest')
set(gca, 'FontSize', 12)

figure(), hold on
for k = 1:b
  plot(results.sg{k}.strain, results.in{k}.stress)
end
% plot(results.in{k}.strain, results.in{k}.stress)

slope = num2str(mean([m(1) m(3)]) / 1000);
str = [slope, ' GPa'];
text(0.4e-3, 9, str, 'FontSize', 12)

slope = num2str(mean([m(2), m(3)])/1000);
str = [slope, ' GPa'];
text(0.8e-3, 7, str, 'FontSize', 12)
xlabel('Strain'), ylabel('Stress')

slope = num2str(m(end)/1000);
str = [slope, ' GPa'];
text(0.85e-3, 12.5, str, 'FontSize', 12)
legend(legText, 'Location', 'SouthEast')
set(gca, 'FontSize', 12)
