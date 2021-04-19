%% ------------------------------------------------------------------------
%  ---- Load experimental data --------------------------------------------
%  ------------------------------------------------------------------------
addpath('C:\Users\Mikanae\Google Drive (maskinne@ualberta.ca)\Pierre_=_ESDLab (FESS Student Projects)\Miles Skinner\Experimental Data\Tensile_Viscoelastic\Tensile tests\Data CSV')
exp_name = {'AL01-02'};
fid = fopen('Exp_List.csv');
exp_list = textscan(fid, '%s%s%s%f%f%f%f%f%f%f%f%f%f%s', 'Delimiter', ',', 'Headerlines', 1);
exp_rows = find(strcmp(exp_name, exp_list{:,1}));

instron_row = exp_rows(strcmp('Instron', exp_list{2}(exp_rows)));
instron_file = [exp_list{3}{instron_row}, '.csv'];
instron_data = csvread(instron_file, 2, 0); % starts at A3

sg_row = exp_rows(strcmp('SG', exp_list{2}(exp_rows)));
  % need if-then statement for separating half and quarter bridge conditions
sg_file = [exp_list{3}{sg_row}, '.csv'];
sg_data = csvread(sg_file, 10, 0); %starts at A11

param_mat = cell2mat(exp_list(6:13));
instron_param = param_mat(instron_row,:);
sg_param = param_mat(sg_row,:); % param order is the column names in exp_list starting at row 6
area = pi * (sg_param(2)^2 - sg_param(1)^2) / 4; % sample cross section area

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
sg_time = sg_data(exp_start_time(end):sg_param(end):end,1);
sg_time(1:exp_start_time(end)) = [];
sg_time = sg_time - sg_time(1);

test = mod(length(instron_data(:,3)),instron_param(end));
if ~test == 0
  instron_data(1:test,:) = [];
end
in_temp = reshape(instron_data(:,3),[instron_param(end),...
  length(instron_data(:,3))/instron_param(end)]);
in_avg_load = mean(in_temp)';
in_time = instron_data(1:instron_param(end):end,1);
in_time = in_time - in_time(1);

in_stress = in_avg_load / area; % [MPa]

V_r = (sg_avg_mv - mean(sg_avg_mv(1:3))) / sg_param(6);

sg_strain = (-4 .* V_r) ./ (sg_param(4).*(1 + 2.*V_r)); % Quarter bridge. Assumes lead resistance of the wires is 0

