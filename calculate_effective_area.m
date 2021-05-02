function [eff_area] = calculate_effective_area(samp_param)
layers = samp_param(3);
c = samp_param(4);
tow = samp_param(5);
alpha = samp_param(6) * (2*pi)/360; %winding angle in radians
fvf = samp_param(7);
tex = samp_param(8) / 1000; % g/m
rho = samp_param(9) * 1000; %converts kg/m^3 to g/m^3

cover = zeros(layers,1);

ri = samp_param(1) / 2000; % converts dia in mm to radius in m

lay = 1;
r_cur = ri; % current radius
while lay <= layers
  cover(lay) = (tex * tow * c) / ((fvf * rho * pi * r_cur + sum(cover)) * cos(alpha));
  r_cur = r_cur + cover(lay);
  lay = lay + 1;
end

avg_cover_thick = mean(cover) * 1000; %average cover thickness in mm
wall_thick = sum(cover) * 1000; %wall thickness in mm
ro = (ri*1000) + wall_thick; %outer radius in mm
eff_area = (ro^2 - (ri*1000)^2) * pi;
