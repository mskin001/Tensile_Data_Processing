function [in, sg] = process_data(eff_area, sg_data, sg_param, instron_data, instron_param, samp_param)
%% ------------------------------------------------------------------------
%  ---- Average data over each second -------------------------------------
%  ------------------------------------------------------------------------
test = mod(length(sg_data(:,2)),sg_param(end));
if ~test == 0
  sg_data(1:test,:) = [];
end

sg_temp = reshape(sg_data(:,2),[sg_param(end),length(sg_data(:,2))/sg_param(end)]);
sg_avg_mv = mean(sg_temp,1)';
% exp_start_time = find(abs(sg_avg_mv(1:50)) <=  mean(abs(sg_avg_mv(1:3))));
exp_start_time = 1;
% sg_avg_mv(1:exp_start_time(end)) = [];
sg_avg_mv = sg_avg_mv / sg_param(5);

sg_time = sg_data(1:sg_param(end):end,1);
sg_time(1:exp_start_time(end)) = [];
sg_time = sg_time - sg_time(1);

test = mod(length(instron_data(:,end)),instron_param(end));
if ~test == 0
  instron_data(1:test,:) = [];
end

in_temp = reshape(instron_data(:,end),[instron_param(end),...
  length(instron_data(:,end))/instron_param(end)]);
in_avg_load = mean(in_temp,1)';
in_avg_load(1:exp_start_time(end)) = [];

in_ext = reshape(instron_data(:,2),[instron_param(end),...
  length(instron_data(:,2))/instron_param(end)]);
in_avg_ext = mean(in_ext,1);
in_avg_ext(1:exp_start_time(end)) = [];

in_time = instron_data(1:instron_param(end):end,1);
in_time(1:exp_start_time(end)) = [];
in_time = in_time - in_time(1);

%% ------------------------------------------------------------------------
%  ---- Process measured data ---------------------------------------------
%  ------------------------------------------------------------------------
in_stress = in_avg_load / eff_area; % [MPa]
in_strain = in_avg_ext / sg_param(3);

if sg_param(1) == 0.25
  % Quarter bridge. Assumes lead resistance of the wires is 0. Always
  % positive.
  V_r = (sg_avg_mv - mean(sg_avg_mv(1:3))) / (sg_param(6)); % - mean(sg_avg_mv(1:3))
  sg_strain = ((4 .* V_r) ./ (sg_param(4).*(1 + 2.*V_r)));
elseif sg_param(1) == 0.5
  % half bridge equation
  V_r = (sg_avg_mv - mean(sg_avg_mv(1:3))) / (sg_param(6));
  sg_strain = abs((-4.*V_r) ./ (sg_param(4)*((1+samp_param(10))...
    - 2.*V_r.*(samp_param(10)-1))));
end

%% ------------------------------------------------------------------------
%  ---- Output results ----------------------------------------------------
%  ------------------------------------------------------------------------
in.stress = in_stress;
in.strain = in_strain;
in.time = in_time;

sg.strain = sg_strain(1:length(in.strain));
sg.time = sg_time(1:length(in.time));




