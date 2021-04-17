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
sample_param = param_mat(sg_row,:); % param order is the column names in exp_list starting at row 6
area = pi * (sample_param(2)^2 - sample_param(1)^2) / 4; % sample cross section area

%% ------------------------------------------------------------------------
%  ---- Average data over each second -------------------------------------
%  ------------------------------------------------------------------------
in_temp = reshape(instron_data(:,3),instron_param(end));
in_avg_load = mean(in_temp);

sg_temp = reshape(sg_data(:,2),sg_param(end));
sg_avg_load = mean(sg_temp);

instron_stress = instron_data(:,3) / area;

V_r = (sg_data(:,2) - mean(sg_data(1:100))) / sample_param(6);

sg_strain = (-4 .* V_r) ./ (sample_param(4).*(1 + 2.*V_r)); % Quarter bridge. Assumes lead resistance of the wires is 0
