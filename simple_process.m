function [] = simple_process(sg_data, instron_data, samp_param, sg_param, eff_area)

vo = sg_data(:,2) / sg_param(5);
sg = (-8 .* vo) ./ ((sg_param(4) .* sg_param(6)) .* (2 + 4.*(vo./sg_param(6))));


end