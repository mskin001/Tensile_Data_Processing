clear, close all

addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\Experimental Data\'...
    'Tensile Viscoelastic'])
% addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\Experimental Data'...
%     '\Tensile Viscoelastic'])

exp_name = {'GF12-01'};
avg_res = true;

legText = {'SG1', 'SG2', 'SG3'};
% legText = {'GF11-01', 'GF11-02', 'GF12-01'};
marker_step = 1000;

exp_type = 'VE';

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
    
    cur_exp = exp_name{1};
    exp_rows = find(strcmp(cur_exp, exp_list{:,1}));
    param_mat = cell2mat(exp_list(5:12));
    
    samp_row = find(strcmp(exp_list{4}{exp_rows(1)},samp_data{1}(:)));
    samp_mat = cell2mat(samp_data(2:11));
    samp_param = samp_mat(samp_row,:);
    if ~strcmp(exp_type, 'VE')
    %% ------------------------------------------------------------------------
    %  ---- Parse Data --------------------------------------------------------
    %  ------------------------------------------------------------------------
    % Necessary with SG data and LC data is not in the same csv. Happens
    % when using the Instron/MTS machine
        addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\Experimental Data\'...
        'Tensile Viscoelastic\Tensile tests\Data CSV'])

%         addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\'...
%             'Experimental Data\Tensile Viscoelastic\Tensile tests\Data CSV'])
        lc_row = exp_rows(strcmp('LC', exp_list{2}(exp_rows)));
        lc_file = [exp_list{3}{lc_row}, '.csv'];
        lc_data = csvread(lc_file, 2, 0); % starts at A3
        lc_param = param_mat(lc_row,:);

        sg_row = exp_rows(strcmp('SG', exp_list{2}(exp_rows)));
        rows = length(sg_row);

        for k = 1:rows
            sg_file = [exp_list{3}{sg_row(k)}, '.csv'];
            sg_data{k+b} = csvread(sg_file, 1, 0); %starts at A11
            sg_param{k+b} = param_mat(sg_row(k),:); % param order is the column names in exp_list starting at C5.
            %Bridge_type, Direction, Gauge_length, Gauge_factor, Gain, Input_voltage,
            %Volume_fraction, Sample rate
        end
    else
    %% ------------------------------------------------------------------------
    %  ---- Parse Data --------------------------------------------------------
    %  ------------------------------------------------------------------------
    % When all data is in the same file from the VE test platform.
        addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\Experimental Data\'...
        'Tensile Viscoelastic\VE'])
        
%         addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\'...
%             'Experimental Data\Tensile Viscoelastic\VE'])
        exp_file = [exp_list{3}{exp_rows}, '.csv'];
        exp_data = csvread(exp_file);
        lc_param = param_mat(exp_rows,:);
        sg_param{1} = lc_param;
        sg_param{1}(1) = 0.25;
        sg_param{2} = sg_param{1};
        sg_param{2}(1) = 0.25;
        
        lc_data = exp_data(:,1:2); % load cell (time, voltage)
        lc_data(:,2) = lc_data(:,2)./2100;
        lc_data(:,2) = lc_data(:,2).* 1.401e6 + 5.888; %converts voltage to load [N]. See load_cell_characterization.m
        
        sg_data{1} = exp_data(:,3:4);
        sg_data{2} = exp_data(:,5:6);
        try
            sg_data{3} = exp_data(:,7:8);
            sg_param{3} = sg_param{2};
        catch
            % do nothing
        end
        rows = length(sg_data);
        
        
    end
    disp('Begin Calculations')
    %% ------------------------------------------------------------------------
    %  ---- Begin Calculations ------------------------------------------------
    %  ------------------------------------------------------------------------
    try
        eff_area = calculate_effective_area(samp_param);
    catch
        %geometric area when winding parameters not available
        eff_area = pi * (samp_param(2)^2 - samp_param(1)^2) / 4; % sample cross section area
    end
    
    if avg_res
        for k = 1:3
            str_data(:,k) = sg_data{k}(:,2);
        end
        str_data = mean(str_data,2);
        str_time = sg_data{1}(:,1);
        sg_data = {[str_time,str_data]};
        rows = 1;
    end
    for k = 1:rows
        % Process Instron and strain gauge data
        [results.lc{k+b}, results.sg{k+b}] = process_data...
          (eff_area, sg_data{k+b}, sg_param{k+b}, lc_data, lc_param, samp_param);

        % Linear regression to find Young's modulus
        % intermediate array before calculating regression values
        intermediate = ([ones(length(results.sg{k+b}.strain),1),...
          results.sg{k+b}.strain]);
        % "\" operator on array for linear regression
        regress = intermediate \ results.lc{k+b}.stress;
        y_int(k+b) = regress(1); % [MPa]
        m(k+b) = regress(2); % slope a.k.a Young's modulus(MPa)
    end
    b = b + rows;
    exp_name(1) = [];

end


disp('begin plotting')
%% ------------------------------------------------------------------------
%  ---- Plotting and output -----------------------------------------------
%  ------------------------------------------------------------------------
marker = ['s', '*', 'o', '+', '^', 'v', 'd'];
line = {'--', '-', ':', '-.', };

figure(1), hold on
for k = 1:b
    plot(results.sg{k}.time/60, results.sg{k}.strain, [line{1+mod(k,4)},marker(1+mod(k,7))]...
        , 'MarkerIndices', 1:marker_step:length(results.sg{k}.time), 'Linewidth', 2);
end
% plot(results.in{k}.time, results.in{k}.strain);
xlabel('time [min]'), ylabel('Strain')
legend(legText, 'Location', 'NorthWest')
% legend('SG1', 'SG2', 'SG3')
grid on
set(gca, 'FontSize', 12)

figure(), hold on
for k = 1:b
    plot(results.sg{k}.strain, results.lc{k}.stress, [line{1+mod(k,4)},marker(1+mod(k,7))]...
        , 'MarkerIndices', 1:marker_step:length(results.sg{k}.time), 'Linewidth', 2);
end
xlabel('Strain'), ylabel('Stress [MPa]')
% legend('Half Bridge', 'Quarter Bridge', 'Location', 'Southeast')
legend(legText, 'Location', 'SouthEast')
grid on
set(gca, 'FontSize', 12)

figure()
plot(results.lc{1}.time, results.lc{1}.stress, 'Linewidth', 2)
xlabel('time [s]'), ylabel('Stress [MPa]')
grid on;
set(gca, 'FontSize', 12)
