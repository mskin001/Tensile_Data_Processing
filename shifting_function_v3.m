clear
close all
% Shifting algorithm is from "The closed form t-T-P shifting (CFS)
% algorithm" by M. Gergesova, B. Zupancic, I. Saprunov, and I. Emri
comp = load('avg_comp');
comp = comp.avg_comp;
exp_time = load('avg_time');
exp_time = exp_time.avg_time;
temps = [35, 45, 60]; % temp in degC
beg_lin_resp = [3, 3, 50];
tref = temps(1);
% 
figure()
marker = ['o+^d'];
for k = 1:length(temps)
    hold on
    plot(exp_time{k}, comp{k}, marker(k),'Linewidth', 1.5)
end
xlabel('log_{10}(t) [min]')
ylabel('Compliance [1/GPa]')
set(gca, 'Fontsize', 12)

% times = raw_times;
% comp = log10(raw_comp);
ref_time = log10(exp_time{1}(beg_lin_resp(1):end))';
ref_comp = log10(comp{1}(beg_lin_resp(1):end))';
best_fit_exten = 100000;
% figure(), hold on, grid on
for k = 1:length(temps) -1
% find overlab region
    next_time = log10(exp_time{k+1}(beg_lin_resp(k+1):end))';
    next_comp = log10(comp{k+1}(beg_lin_resp(k+1):end))';
%     hold on
%     plot(ref_time,ref_comp)
%     plot(next_time, next_comp)
    [~, ol_start] = min(next_comp);
    [~, ol_end] = max(ref_comp);
    u_ind = find(next_comp(:,1) >= next_comp(ol_start) & next_comp(:,1) <= ref_comp(ol_end));
    l_ind = find(ref_comp(:,1) >= next_comp(ol_start) & ref_comp(:,1) <= ref_comp(ol_end));

    U = [next_time(u_ind), next_comp(u_ind)];
    L = [ref_time(l_ind), ref_comp(l_ind)];

    % A is an intermediate variable representing the area within the overlaping
    % region of the two compliance curves
    A = sum((0.5 * (L(2:end,1) + L(1:end-1,1))) .* (L(2:end,2) - L(1:end-1,2)));

    % b is an intermediate variable
    b = sum((0.5 * (U(2:end,1) + U(1:end-1,1))) .* (U(2:end,2) - U(1:end-1,2)));
    
    try
        log_shift_factor = (A - b) / (L(end,2) - U(1,2));
    catch
        log_shift_factor = nan;
    end
    
    while isnan(log_shift_factor) || isinf(log_shift_factor)
        [fitresult, ~] = ref_best_fit(ref_time, ref_comp);
        time = ref_time;
        time_ext = log10(linspace(10^ref_time(end),10^ref_time(end)+best_fit_exten,best_fit_exten));
        time(end+1:end+length(time_ext)) = time_ext;
        comp_ext = fitresult.a .* time.^(fitresult.b) + fitresult.c;
        plot(time,comp_ext)
        hold on
        plot(ref_time, ref_comp)
        plot(next_time, next_comp)
        [~, ol_start] = min(next_comp);
        [~, ol_end] = max(comp_ext);
        u_ind = find(next_comp(:,1) >= next_comp(ol_start) & next_comp(:,1) <= comp_ext(ol_end));
        l_ind = find(comp_ext(:,1) >= next_comp(ol_start) & comp_ext(:,1) <= comp_ext(ol_end));

        U = [next_time(u_ind), next_comp(u_ind)];
        L = [time(l_ind), comp_ext(l_ind)];

        % A is an intermediate variable representing the area within the overlaping
        % region of the two compliance curves
        A = sum((0.5 * (L(2:end,1) + L(1:end-1,1))) .* (L(2:end,2) - L(1:end-1,2)));

        % b is an intermediate variable
        b = sum((0.5 * (U(2:end,1) + U(1:end-1,1))) .* (U(2:end,2) - U(1:end-1,2)));
        
        try
          log_shift_factor = (A - b) / (L(end,2) - U(1,2));
        catch
          log_shift_factor = NaN;
        end
        
        best_fit_exten = best_fit_exten*100
    end
        
    shift_factor = 10^(log_shift_factor);
    shifted_time = next_time + log_shift_factor;
    ref_time = [ref_time; shifted_time];
    ref_comp = [ref_comp; next_comp];
    
    figure(), hold on
    loglog(ref_time, ref_comp, '-o', 'LineWidth', 1.5)
    loglog(next_time, next_comp, '-*', 'LineWidth', 1.5)
    loglog(shifted_time, next_comp, '-+', 'LineWidth', 1.5)
end
xlabel('log(t) [min]')
ylabel('log(D) [1/GPa]')

mc = 10.^ref_comp;

[fitresult, gof] = ref_best_fit(ref_time(3:end), ref_comp(3:end));
fit_time = linspace(ref_time(1),ref_time(end),length(ref_time));
fit_comp = fitresult.a .* fit_time.^(fitresult.b) + fitresult.c;

figure()
hold on
plot(ref_time,mc, 'k^', 'LineWidth', 1.5)
marker = ['o+^d'];
for k = 1:length(temps)
    hold on
    plot(log10(exp_time{k}), comp{k}, marker(k),'Linewidth', 1.5)
end
plot(fit_time,10.^fit_comp, '-', 'Linewidth', 1.5)
grid on
set(gca, 'Fontsize', 12)
xlabel('log_{10}(t) [sec]')
ylabel('Compliance [1/Pa]')
legend({'Shifted Curves', '30^oC', '45^oC', '60^oC', 'Master Curve'},...
    'Location', 'southeast')

