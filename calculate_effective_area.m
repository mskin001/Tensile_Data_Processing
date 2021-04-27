function [eff_area] = calculate_effective_area(samp_param)
layers = samp_param(4);
c = samp_param(5);
tow = samp_param(6);
alpha = samp_param(7);
fvf = samp_param(8);
tex = samp_param(9);
rho = samp_param(10);

cover = zero(layers,1);

ri = samp_param(1) / 2000; % converts dia in mm to radius in m

lay = 1;
r_cur = ri; % current radius
while lay <= 10
  cover(lay) = (tex * tow * c) / (fvf * rho * pi * r_cur + sum(cover)) * cos(alpha);
  r_cur = r_cur + cover(lay);
  lay = lay + 1;
end

avg_cover_thick = mean(cover);
wall_thick = sum(cover);
ro = ri + wall_thick;
