%% ------------------------------------------------------------------------
%  ---- Load experimental data --------------------------------------------
%  ------------------------------------------------------------------------
addpath('C:\Users\Mikanae\Google Drive (maskinne@ualberta.ca)\Pierre_=_ESDLab (FESS Student Projects)\Miles Skinner\Experimental Data\Tensile_Viscoelastic\Tensile tests\Data CSV')
exp_name = {'GF04-02'};
bridge = 1; % specify bridge type. 1 = half, 2 = quarter

fid = fopen('Exp_List.csv');
exp_list = textscan(fid, '%s%s%s%s%f%f%f%f%f%f%f%f%s', 'Delimiter', ',', 'Headerlines', 1);
fclose(fid);

fid = fopen('Sample_Data.csv');
samp_data = textscan(fid, '%s%f%f%f%f%f%f%f%f%f%f', 'Delimiter', ',', 'Headerlines', 1);
fclose(fid);

exp_rows = find(strcmp(exp_name, exp_list{:,1}));

instron_row = exp_rows(strcmp('Instron', exp_list{2}(exp_rows)));
instron_file = [exp_list{3}{instron_row}, '.csv'];
instron_data = csvread(instron_file, 2, 0); % starts at A3

sg_row = exp_rows(strcmp('SG', exp_list{2}(exp_rows)));
  % need if-then statement for separating half and quarter bridge conditions
sg_file = [exp_list{3}{sg_row(bridge)}, '.csv'];
sg_data = csvread(sg_file, 10, 0); %starts at A11

samp_row = find(strcmp(exp_list{4}{exp_rows(1)},samp_data{1}(:)));
samp_mat = cell2mat(samp_data(2:11));
samp_param = samp_mat(samp_row,:);

param_mat = cell2mat(exp_list(5:12));
instron_param = param_mat(instron_row,:);
sg_param = param_mat(sg_row(bridge),:); % param order is the column names in exp_list starting at C5.
  %Bridge_type, Direction, Gauge_length, Gauge_factor, Gain, Input_voltage,
  %Volume_fraction, Sample rate

try
  eff_area = calculate_effective_area(samp_param);
catch
  %geometric area when winding parameters not available
  eff_area = pi * (samp_param(2)^2 - samp_param(1)^2) / 4; % sample cross section area
end
%% ------------------------------------------------------------------------
%  ---- Average data over each second -------------------------------------
%  ------------------------------------------------------------------------
test = mod(length(sg_data(:,2)),sg_param(end));
if ~test == 0
  sg_data(1:test,:) = [];
end

sg_temp = reshape(sg_data(:,2),[sg_param(end),length(sg_data(:,3))/sg_param(end)]);
sg_avg_mv = mean(sg_temp)';
exp_start_time = find(abs(sg_avg_mv(1:50)) <=  mean(abs(sg_avg_mv(1:3))));
sg_avg_mv(1:exp_start_time(end)) = [];
sg_avg_mv = sg_avg_mv / sg_param(5);

sg_time = sg_data(exp_start_time(end):sg_param(end):end,1);
sg_time(1:exp_start_time(end)) = [];
sg_time = sg_time - sg_time(1);

test = mod(length(instron_data(:,3)),instron_param(end));
if ~test == 0
  instron_data(1:test,:) = [];
end

% simple_process(sg_data, instron_data, samp_param, sg_param)

in_temp = reshape(instron_data(:,3),[instron_param(end),...
  length(instron_data(:,3))/instron_param(end)]);
in_avg_load = mean(in_temp)';

in_ext = reshape(instron_data(:,2),[instron_param(end),...
  length(instron_data(:,2))/instron_param(end)]);
in_avg_ext = mean(in_ext);

in_time = instron_data(1:instron_param(end):end,1);
in_time = in_time - in_time(1);

in_stress = in_avg_load / eff_area; % [MPa]
in_strain = in_avg_ext / sg_param(3);

if sg_param(1) == 0.25
    % Quarter bridge. Assumes lead resistance of the wires is 0. Always
  % positive.
  V_r = (sg_avg_mv - mean(sg_avg_mv(1:3))) / (sg_param(6));
  sg_strain = abs((-4 .* V_r) ./ (sg_param(4).*(1 + 2.*V_r)));
  sg = (-8 .* sg_avg_mv) ./ ((sg_param(4) .* sg_param(6)) .* (2 + 4.*(sg_avg_mv./sg_param(6))));
elseif sg_param(1) == 0.5
  % half bridge equation
  V_r = (sg_avg_mv - mean(sg_avg_mv(1:3))) / (sg_param(6));
  sg_strain = abs((-4.*V_r) ./ (sg_param(4)*(1+samp_param(10) - 2.*V_r.*(samp_param(10)-1))));
end

figure(), hold on
plot(in_time, in_strain, 'b-');
plot(sg_time, sg_strain, 'r-');

figure(), hold on
plot(sg_strain(1:length(in_stress)), in_stress, 'r-')
plot(in_strain, in_stress, 'b-')



