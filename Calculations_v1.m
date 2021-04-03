close all
% Note: "voltage", "Load", and "Extension" were imported from the
% raw Excel data
load('matlab.mat')
E = 68.9*10^9; % elastic modulus for AL6061
v = 0.33; % poisson's ratio for AL6061

gauge_length = 25; % gauge length on tensile sample
k = 2.09; % gauge factor
voltage_source = 5; % excitation voltage

%-------------------------------------------------------------------------------
% Begin Program
%-------------------------------------------------------------------------------
area = (pi/4)*(0.375^2)*(25.4^2)*(1/1000)^2; % m^2

%------ Find strain from applied load and extension ----------------------------
load_stress = Load/area;
load_strain = load_stress / E;
ext_strain = Extension/gauge_length;

%------ Strain from voltage ----------------------------------------------------
% Subtracting initial voltage value from array and inverting sign
% so final calculated strain will be positive using the formula
initial_V = sum(Voltage(1:87))/length(Voltage(1:87));
voltage_modified = -(Voltage - initial_V)/100;

% Carrying out strain calculation on the array using given equation
gauge_strain = (1/(1+v))*(4/k)*((voltage_modified)/voltage_source);
gauge_stress = E * gauge_strain;
% Converting strain into extension

gauge_extension = gauge_strain*gauge_length;

% Plotting
% figure(1)
% plot(linspace(1,length(Voltage),length(Voltage)),Voltage,'b-')

figure(2)
hold on
% plot(load_strain, load_stress*10^-6, 'b-')
% plot(ext_strain, load_stress*10^-6, 'r-')
plot(gauge_strain(1:length(load_strain)), load_strain, 'k-')
% title('Aluminum 6061 Load-Strain')
ylabel('Stress [MPa]')
xlabel('Strain')
legend('Expected', 'Instron Extension', 'Strain Gauge', 'Location', 'southeast');
set(gca, 'Fontsize', 14)
grid on
