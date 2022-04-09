% the time (t) for key points: load applied, load removed, begin average
% time, end average time. Average time is used to find the average load and
% remove outliers

exps = {'GF12-01-results', 'GF13-05-results'};

for w = 1:length(exps)
    load(exps{w});
% str_markers = [2264, 4113, 2402, 4021;
%                 1.407e4, 1.591e4, 1.42e4, 1.582e4;
%                 2.381e4, 2.566e4, 2.392e4, 2.555e4]; %GF11-01
% str_markers = [2235, 4396, 2298, 4343;
%                 1.358e4, 1.547e4, 1.372e4, 1.538e4;
%                 2.485e4, 2.667e4, 2.49e4, 2.663e4]; %GF11-02
    if strcmp(exps{w},'GF12-01-results')
    str_markers = [4239, 6176, 4367, 6080;
                    1.6309e4, 1.819e4, 1.651e4, 1.799e4;
                    2.6325e4, 2.8174e4, 2.643e4, 2.808e4]; %GF12-01
    else
    str_markers = [2304, 4241, 2478, 4002;
                    13527, 15408, 13621, 15189;
                    21387, 23236, 21550, 23147]; %GF13-05
    end
            
    cte = [-8.19, -29.39, -45.3]* 10^-6;
    [rows, cols] = size(str_markers);


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

        sg_strain{w,b} = sg(str_markers(b,1):str_markers(b,2)) - cte(b);
        comp{w,b} = sg_strain{w,b}./(lc_str * 10^6);

        exp_time{w,b} = time(str_markers(b,1):str_markers(b,2)) - time(str_markers(b,1));

    end
    sg = [];
end

% avg_comp = mean(comp,2)';
if length(exps) > 1
    for k = 1:rows
        a = {sg_strain{1,k}', sg_strain{2,k}'};
        maxNumCol = max(cellfun(@(c) size(c,2),a));
        aMat = cell2mat(cellfun(@(c){padarray(c,[0,maxNumCol-size(c,2)],NaN,'Post')}, a)');
        avg_strain{k} = mean(aMat,1,'omitnan');

        a = {comp{1,k}', comp{2,k}'};
        maxNumCol = max(cellfun(@(c) size(c,2),a));
        aMat = cell2mat(cellfun(@(c){padarray(c,[0,maxNumCol-size(c,2)],NaN,'Post')}, a)');
        avg_comp{k} = mean(aMat,1,'omitnan');

        a = {exp_time{1,k}', exp_time{2,k}'};
        maxNumCol = max(cellfun(@(c) size(c,2),a));
        aMat = cell2mat(cellfun(@(c){padarray(c,[0,maxNumCol-size(c,2)],NaN,'Post')}, a)');
        avg_time{k} = mean(aMat,1,'omitnan');
    end
else
    avg_strain = sg_strain;
    avg_comp = comp;
    avg_time = exp_time;
end

avg_strain{2}(1835:end) = [];
avg_strain{1}(1846:end) = [];
avg_comp{2}(1835:end) = [];
avg_comp{1}(1846:end) = [];
avg_time{2}(1835:end) = [];
avg_time{1}(1846:end) = [];

figure()
hold on
for k = 1:rows
    plot(avg_time{k},avg_strain{k}, 'Linewidth', 2)
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
    plot(avg_time{k},avg_comp{k}, 'Linewidth', 2)
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
    plot(log10(avg_time{k}),avg_comp{k}, 'Linewidth', 2)
end
xlabel('log_{10}(t)')
ylabel('Compliance [Pa^{-1}]')
legend('30^oC', '45^oC', '60^oC', 'Location', 'Northwest')
grid on
set(gca, 'Fontsize', 12)

% plot(log10(time(1:length(comp(:,k)))),avg_comp)
