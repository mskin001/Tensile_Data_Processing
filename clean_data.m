function [comp] = clean_data(results)
% the time (t) for key points: load applied, load removed, begin average
% time, end average time. Average time is used to find the average load and
% remove outliers
str_markers = [63, 1.254e4, 4078, 1.177e4];

load('results_test.mat');
% allocate variables
time = results.lc{1}.time;
lc = results.lc{1}.stress;
for k = 1:length(results.sg)
    sg(:,k) = results.sg{k}.strain;
end

% get index locations for key points
for k = 1:length(str_markers)
    ind(k) = find(time == str_markers(k));
end

% remove outliers in str
str_avg = mean(lc(ind(4):ind(end),1));
lc_str = lc(str_markers(1):str_markers(2),1);
tf = isoutlier(lc_str);
lc_str(tf) = str_avg;

for k = 1:length(results.sg)
    comp(:,k) = sg(str_markers(1):str_markers(2),k)./lc_str;
end
% comp(:,1) = hb_sg(str_markers(1):str_markers(2))./lc_str;
% comp(:,2) = qb_sg(str_markers(1):str_markers(2))./lc_str;

avg_comp = mean(comp,2)';
figure()
hold on
for k = 1:2
    plot(log10(time(1:length(comp(:,k)))),comp(:,k))
end
plot(log10(time(1:length(comp(:,k)))),avg_comp)
end
