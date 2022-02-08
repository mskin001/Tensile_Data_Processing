clear, close all

addpath(['H:\My Drive\FESS Student Projects\Miles Skinner\Experimental Data\'...
    'Tensile Viscoelastic'])

exp_name = {'GF11-01-Prelim'};
legText = {'H-05-01', 'Q-05-01', 'H-05-02', 'Q-05-02', 'H-08-01', 'Q-08-01', 'H-09-01',...
  'Q-09-01', 'H-10-01', 'Q-10-01'};
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
        lc_row = exp_rows(strcmp('LC', exp_list{2}(exp_rows)));
        lc_file = [exp_list{3}{lc_row}, '.csv'];
        lc_data = csvread(lc_file, 2, 0); % starts at A3
        lc_param = param_mat(lc_row,:);

        sg_row = exp_rows(strcmp('SG', exp_list{2}(exp_rows)));
        rows = length(sg_row);

        for k = 1:rows
            sg_file = [exp_list{3}{sg_row(k)}, '.csv'];
            sg_data{k+b} = csvread(sg_file, 10, 0); %starts at A11
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
        
        exp_file = [exp_list{3}{exp_rows}, '.csv'];
        exp_data = csvread(exp_file);
        lc_param = param_mat(exp_rows,:);
        sg_param{1} = lc_param;
        sg_param{1}(1) = 0.5;
        sg_param{2} = sg_param{1};
        sg_param{2}(1) = 0.5;
        
        lc_data = exp_data(:,1:2); % load cell (time, voltage)
        lc_data(:,2) = lc_data(:,2)./2100;
        lc_data(:,2) = lc_data(:,2).* 1.401e6 + 5.888; %converts voltage to load [N]. See load_cell_characterization.m
        
        sg_data{2} = exp_data(:,5:6); % half bridge (time, voltage)
        sg_data{1} = exp_data(:,3:4); % quarter bridge (time, volatge)
        try
            sg_data{3} = exp_data(:,7:8);
            sg_param{3} = sg_param{2};
        catch
            continue
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

% results.comp(1,:) = results.sg{1}.strain(64:12000) ./ results.lc{1}.stress(64:12000);
% results.comp(2,:) = results.sg{2}.strain(64:12000) ./ results.lc{2}.stress(64:12000);
% figure()
% hold on
% plot(log10(results.sg{1}.time(1:length(results.comp(1,:)))),results.comp(1,:))
% plot(log10(results.sg{2}.time(1:length(results.comp(2,:)))),results.comp(2,:))
disp('begin plotting')
%% ------------------------------------------------------------------------
%  ---- Plotting and output -----------------------------------------------
%  ------------------------------------------------------------------------
marker = ['*', 'o', '^'];

figure(), hold on
for k = 1:b
    plot(results.sg{k}.time, results.sg{k}.strain, ['-', marker(k)], 'MarkerIndices',...
        1:1000:length(results.sg{k}.time),  'Linewidth', 2);
end
% plot(results.in{k}.time, results.in{k}.strain);
xlabel('time [s]'), ylabel('Strain')
% legend(legText, 'Location', 'NorthWest')
legend('SG1', 'SG2', 'SG3')
grid on
set(gca, 'FontSize', 12)



figure(), hold on
for k = 1:b
    plot(log10(results.sg{k}.time), results.sg{k}.strain);
end
% plot(results.in{k}.time, results.in{k}.strain);
xlabel('log(t) [s]'), ylabel('Strain')
% legend(legText, 'Location', 'NorthWest')
set(gca, 'FontSize', 12)

figure(), hold on
for k = 1:b
    plot(results.sg{k}.strain, results.lc{k}.stress)
end
xlabel('Strain'), ylabel('Stress [MPa]')
legend('Half Bridge', 'Quarter Bridge', 'Location', 'Southeast')
slope = num2str(mean([m(1)]) / 1000);
str = [slope, ' GPa'];
text(0.1e-3, 13, str, 'FontSize', 12)

slope = num2str(mean([m(2)])/1000);
str = [slope, ' GPa'];
text(0.45e-3, 7, str, 'FontSize', 12)
xlabel('Strain'), ylabel('Stress')

% slope = num2str(m(end)/1000);
% str = [slope, ' GPa'];
% text(0.85e-3, 12.5, str, 'FontSize', 12)
% legend(legText, 'Location', 'SouthEast')
set(gca, 'FontSize', 12)

figure()
plot(results.lc{1}.time, results.lc{1}.stress, 'Linewidth', 2)
xlabel('time [s]'), ylabel('Stress [MPa]')
set(gca, 'FontSize', 12)
