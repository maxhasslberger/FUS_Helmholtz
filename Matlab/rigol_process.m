%% Input param
path = 'Data/Dummy/';
channel = 1; % Rigol channel
dx = 1.0 * 1e-3; % m
offset = [30.0, 10.0]; % mm
center_frq = 2.0; % MHz -> Transducer frq
amp_flag = 0; % amplifier used between hydrophone - DAQ?

% LUT for hydrophone and amplifiers
lut.F0 = [0.5, 2.0, 15.0]; % MHz
lut.gain = [530.9, 530.9, 530.9]; % NP-2519 amplifier -> ~54.5 dB (small signal)-> ~ 60 dB for very small signals!
lut.hyd_TF = [188.4 * 1e-9, 158.5 * 1e-9, 105.9 * 1e-9]; % Onda HNR-0500 hydrophone (V/Pa) -> [~-254.5, ~-256.0, ~-259.5] dB

dim = 2;
%% Load and merge files
files = dir(strcat(path, '*.csv'));
data = [];
pos = [];
% pos = zeros(length(files), dim);

pos_ind = zeros(1, dim);
for i=1:length(files)
%     tmp = load(files(i).name).dataset;
    tmp = importdata(strcat(path, files(i).name));
    
    % Extract position
    tmp_pos = files(i).name;
    tmp_pos = tmp_pos(1:find(tmp_pos == 'F')-1); % Discard file ending
    tmp_pos = str2double(regexp(tmp_pos,'\d*','match')');
    
    % Align data
    new_pos = tmp_pos > pos_ind;
    pos_ind = pos_ind + new_pos;
    new_inds = find(new_pos(1:end-1));
    pos_ind(new_inds + 1) = 0;
    
    pos(pos_ind(1) + 1, pos_ind(2) + 1, :) = tmp_pos;
    data(pos_ind(1) + 1, pos_ind(2) + 1, :, :) = tmp.data; % Data: timestamp, Ch1, Ch2
end

%% Process
% Pressure conversion
lut_idx = find(lut.F0 == center_frq);
pressure = data(:, :, :, channel+1) * lut.gain(lut_idx)^amp_flag / lut.hyd_TF(lut_idx); % Ch1 signal converted to Pa

% signal = rms(data(:, :, :, channel+1), 3);
% pressure_signal = rms(pressure, 3);
signal = (max(data(:, :, :, channel+1), [], 3) - min(data(:, :, :, channel+1), [], 3)) / 2;
pressure_signal = (max(abs(pressure), [], 3) - min(abs(pressure), [], 3)) / 2;

%% Plot
% surf(pos(:, :, 1) * dx, pos(:, :, 2) * dx, pressure_signal, 'edgecolor', 'none');
% view(2);
% contourf(unique(pos(:, 1)), unique(pos(:, 2)), peaks);
pcolor(pos(:, :, 1) * dx * 1e3 - offset(1), pos(:, :, 2) * dx * 1e3 - offset(2), pressure_signal);
xlabel('x (mm)');
ylabel('y (mm)');
a = colorbar;
ylabel(a,'Pressure (Pa)','FontSize',16,'Rotation',90);








