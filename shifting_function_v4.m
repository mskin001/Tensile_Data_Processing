function [ref_time, mc] = shifting_function_v4(ref_time, ref_comp, next_time, next_comp)
% Shifting algorithm is from "The closed form t-T-P shifting (CFS)
% algorithm" by M. Gergesova, B. Zupancic, I. Saprunov, and I. Emri
% comp = load('GF12-01-comp-test');
% comp = comp.comp;
% exp_time = load('GF12-01-rt-test');
% exp_time = exp_time.ref_time;
% temps = [35, 45, 60]; % temp in degC
% tref = temps(1);
% 
% figure()
% marker = ['o+^d'];
% for k = 1:length(temps)
%     hold on
%     plot(exp_time{k}, comp{k}, marker(k),'Linewidth', 1.5)
% end
% xlabel('log_{10}(t) [min]')
% ylabel('Compliance [1/GPa]')
% set(gca, 'Fontsize', 12)

% times = raw_times;
% comp = log10(raw_comp);
% ref_time = exp_time{1};
ref_comp = log10(ref_comp);
ref_time = log10(ref_time);
next_comp = log10(next_comp);
next_time = log10(next_time);

figure(), hold on
% for k = 1:length(temps) -1
% find overlab region
%     next_time = exp_time{k+1};
%     next_comp = log10(comp{k+1});
plot(ref_time,ref_comp)
plot(next_time, next_comp)
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

log_shift_factor = (A - b) / (L(end,2) - U(1,2));
shift_factor = 10^(log_shift_factor);
shifted_time = next_time + log_shift_factor;
ref_time = [ref_time; shifted_time];
ref_comp = [ref_comp; next_comp];

hold on
%     loglog(ref_time, ref_comp, '-o', 'LineWidth', 1.5)
loglog(next_time, next_comp, '-*', 'LineWidth', 1.5)
loglog(shifted_time, next_comp, '-+', 'LineWidth', 1.5)
% end
figure(2)
xlabel('log(t) [min]')
ylabel('log(D) [1/GPa]')

mc = 10.^ref_comp;

figure(3)
hold on
plot(ref_time,master_comp, 'k^', 'LineWidth', 1.5)
marker = ['o+^d'];
for k = 1:length(temps)
    hold on
    plot(raw_times(:,k), raw_comp(:,k), marker(k),'Linewidth', 1.5)
end
grid on
set(gca, 'Fontsize', 12)
xlabel('log_{10}(t) [s]')
ylabel('Compliance [1/GPa]')
legend({'Master Curve', '40^oC', '50^oC', '60^oC', '70^oC', })

