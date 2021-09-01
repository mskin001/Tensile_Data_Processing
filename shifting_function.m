temps = [40, 50, 60, 70]; % temp in degC
tref = temps(1);

t1 = load('forty_deg.csv');
t2 = load('fifty_deg.csv');
t3 = load('sixty_deg.csv');
t4 = load('seventy_deg.csv');


raw_times(:,1) = t1(:,1);
raw_times(:,2) = t2(:,1);
raw_times(:,3) = t3(:,1);
raw_times(:,4) = t4(:,1);

raw_comp(:,1) = t1(:,2);
raw_comp(:,2) = t2(:,2);
raw_comp(:,3) = t3(:,2);
raw_comp(:,4) = t4(:,2);


times = log(raw_times);
comp = log(raw_comp);

% find overlab region
ref_time = times(:,1);
ref_comp = comp(:,1);

next_time = times(:,2);
next_comp = comp(:,2);

[~, ol_start] = min(next_comp);
[~, ol_end] = max(ref_comp);
u_ind = find(next_comp(:,1) >= next_comp(ol_start) & next_comp(:,1) <= ref_comp(ol_end));
l_ind = find(ref_comp(:,1) >= next_comp(ol_start) & ref_comp(:,1) <= ref_comp(ol_end));

U = [next_time(u_ind), next_comp(u_ind)];
L = [ref_time(l_ind), ref_comp(l_ind)];

for k = 1:length(U) - 1
    


