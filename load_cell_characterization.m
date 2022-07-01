lc_data = load('Load Cell 1.csv');
lc_samp_rate = 10;
lc_gain = 1900;
mts_data = load('MTS810 LoadCell1.csv');
mts_samp_rate = 10;


test = mod(length(lc_data(:,2)),lc_samp_rate);
if ~test == 0
  lc_data(1:test,:) = [];
end

lc_temp = reshape(lc_data(:,2),[lc_samp_rate,length(lc_data(:,2))/lc_samp_rate]);
lc_avg_mv = mean(lc_temp)';
exp_start_time = find(abs(lc_avg_mv(1:50)) <=  mean(abs(lc_avg_mv(1:3))));
lc_avg_mv(1:exp_start_time(end)) = [];
lc_avg_mv = lc_avg_mv / lc_gain;

lc_time = lc_data(exp_start_time(end):lc_samp_rate:end,1);
lc_time(1:exp_start_time(end)) = [];
lc_time = lc_time - lc_time(1);

lc = [lc_time, lc_avg_mv];
[~,ind] = min(lc_avg_mv);
lc(1:ind,:) = [];

test = mod(length(mts_data(:,3)),mts_samp_rate);
if ~test == 0
  mts_data(1:test,:) = [];
end

mts_temp = reshape(mts_data(:,3),[mts_samp_rate, length(mts_data(:,3))/mts_samp_rate]);
mts_avg_load = mean(mts_temp)';

mts_ext = reshape(mts_data(:,2),[mts_samp_rate, length(mts_data(:,2))/mts_samp_rate]);
mts_avg_ext = mean(mts_ext);

mts_time = mts_data(1:mts_samp_rate:end,1);
mts_time = round(mts_time - mts_time(1));

mts = [mts_time, mts_avg_load];
[~,ind] = min(mts_avg_load);
mts(1:ind,:) = [];

bf_x = lc(1:length(mts(:,2)),2);
bf_y = mts(:,2);
[fitresult, gof] = lc_fit(bf_x, 9.81*bf_y)

