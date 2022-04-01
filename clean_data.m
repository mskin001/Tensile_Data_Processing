function [comp] = clean_data(results)
% the time (t) for key points: load applied, load removed, begin average
% time, end average time. Average time is used to find the average load and
% remove outliers
% str_markers = [2264, 4113, 2402, 4021;
%                 1.407e4, 1.591e4, 1.42e4, 1.582e4;
%                 2.381e4, 2.566e4, 2.392e4, 2.555e4]; %GF11-01
% str_markers = [2235, 4396, 2298, 4343;
%                 1.358e4, 1.547e4, 1.372e4, 1.538e4;
%                 2.485e4, 2.667e4, 2.49e4, 2.663e4]; %GF11-02
str_markers = [4239, 6176, 4367, 6080;
                1.635e4, 1.819e4, 1.651e4, 1.799e4;
                2.633e4, 2.815e4, 2.643e4, 2.808e4];
            
cte = [8.19, 29.39, 45.3]* 10^-6;
[rows, cols] = size(str_markers);

load('GF12-01-results');
% allocate variables
time = results.lc{1}.time;
lc = results.lc{1}.stress;
for k = 1:length(results.sg)
    sg(:,k) = results.sg{k}.strain;
end

for b = 1:rows
% get index locations for key points
    for k = 1:cols
        ind(k) = find(time == str_markers(b,k));
    end

    % remove outliers in str
    str_avg = mean(lc(ind(3):ind(end),1));
    lc_str = lc(str_markers(b,1):str_markers(b,2),1);
    tf = isoutlier(lc_str);
    lc_str(tf) = str_avg;

    sg_strain{b} = sg(str_markers(b,1):str_markers(b,2)) - cte(b);
    comp{b} = sg_strain{b}./(lc_str * 10^6);
    
    ref_time{b} = time(str_markers(b,1):str_markers(b,2)) - time(str_markers(b,1));

end

% avg_comp = mean(comp,2)';

figure()
hold on
for k = 1:rows
    plot(ref_time{k},sg_strain{k})
end
xlabel('time [s]')
ylabel('Strain')
legend('30^oC', '45^oC', '60^oC', 'Location', 'Northwest')
grid on
set(gca, 'Fontsize', 12)

% Compliance vs time
figure()
hold on
for k = 1:rows
    plot(ref_time{k},comp{k})
end
xlabel('time [s]')
ylabel('Compliance [Pa^{-1}]')
legend('30^oC', '45^oC', '60^oC', 'Location', 'Northwest')
grid on
set(gca, 'Fontsize', 12)

% Compliance vs log(time)
figure()
hold on
for k = 1:rows
    plot(log10(ref_time{k}),comp{k})
end
xlabel('log_{10}(t)')
ylabel('Compliance [Pa^{-1}]')
legend('30^oC', '45^oC', '60^oC', 'Location', 'Northwest')
grid on
set(gca, 'Fontsize', 12)

% plot(log10(time(1:length(comp(:,k)))),avg_comp)
end
