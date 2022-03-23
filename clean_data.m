function [comp] = clean_data(results)
% the time (t) for key points: load applied, load removed, begin average
% time, end average time. Average time is used to find the average load and
% remove outliers
% str_markers = [2261, 4113, 2402, 4021;
%                 1.407e4, 1.591e4, 1.42e4, 1.582e4;
%                 2.381e4, 2.566e4, 2.392e4, 2.555e4];
str_markers = [2235, 4396, 2298, 4343;
                1.358e4, 1.547e4, 1.372e4, 1.538e4;
                2.485e4, 2.669e4, 2.49e4, 2.663e4];
[rows, cols] = size(str_markers);

load('GF11-02-results');
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


    comp{b} = sg(str_markers(b,1):str_markers(b,2))./lc_str;

end

% avg_comp = mean(comp,2)';
figure()
hold on
for k = 1:rows
    plot(log10(time(1:length(comp{k}))),comp{k})
end
% plot(log10(time(1:length(comp(:,k)))),avg_comp)
end
