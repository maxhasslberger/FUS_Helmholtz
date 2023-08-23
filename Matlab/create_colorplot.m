%% Input param
path = fullfile('Data/15MHz_unfoc_char/');
channel = 1; % oscilloscope channel
dx = 1.0 * 1e-3; % m - dx on resulting color plot
offset = [6.5 * 1e-3, 0.0 * 1e-3]; % m - for color plot
center_frq = 14.2 * 1e6; % Hz -> Transducer frq
amp_flag = 0; % amplifier used between hydrophone - DAQ?
fs = 100 * 1e6;

% LUT for hydrophone and amplifiers
lut.F0 = [0.5, 2.0, 14.2] * 1e6; % Hz
lut.gain = [530.9, 530.9, 530.9]; % NP-2519 amplifier -> ~54.5 dB (small signal)-> ~ 60 dB for very small signals!
lut.hyd_TF = [188.4 * 1e-9, 158.5 * 1e-9, 105.9 * 1e-9]; % Onda HNR-0500 hydrophone (V/Pa) -> [~-254.5, ~-256.0, ~-259.5] dB

%% Load and merge files
folders = dir(path);
folders = folders(3:end); % skip . and ..
signal = NaN(length(folders));

avg_elements = 10;

for hor = 1:length(folders)
    ext_path = strcat(path, folders(hor).name, '/');
    disp(strcat('Processing: ', ext_path))
    files = dir(strcat(ext_path, '*.csv'));
    
    vert_idx = 1;
    for vert = 1:length(files)
        if ~contains(files(vert).name, 'Waveform Data')
            continue;
        end
        %% Compute representative position value
%         % Std encoding
%         data = importdata(strcat(ext_path, files(vert).name));
        % Instrument studio encoding
        data = readmatrix(strcat(ext_path, files(vert).name));
        if size(data, 2) > 1
            data = data(:, channel);
        end

        % BP filter signal
        [b, a] = butter(7, center_frq*0.8 /(fs/2), "high");
        data = filter(b, a, data);

        [b, a] = butter(7, center_frq*1.2 /(fs/2), "low");
        data = filter(b, a, data);
        
        % Determine amplitude and store
        max_avg = +mean(maxk(findpeaks(+data), avg_elements));
        min_avg = -mean(maxk(findpeaks(-data), avg_elements));
        datapoint = (max_avg - min_avg) / 2;
        
        signal(vert_idx, hor) = datapoint;
        vert_idx = vert_idx + 1;
    end
end


%% Process
% Discard NaN rows and cols
signal(:, all(isnan(signal), 1)) = [];
signal(all(isnan(signal), 2), :) = [];

% Pressure conversion
lut_idx = find(lut.F0 == center_frq);
pressure = signal * lut.gain(lut_idx)^amp_flag / lut.hyd_TF(lut_idx); % Voltage signal converted to Pa

%% Plot
% surf(pos(:, :, 1) * dx, pos(:, :, 2) * dx, pressure_signal, 'edgecolor', 'none');
% view(2);
% contourf(unique(pos(:, 1)), unique(pos(:, 2)), peaks);
pcolor(((0:size(pressure, 2)-1) * dx - offset(1)) * 1e3, ((0:size(pressure, 1)-1) * dx - offset(2)) * 1e3, pressure / 1e6);
xlabel('x (mm)');
ylabel('y (mm)');
title('V319-SU, Olympus (15 MHz), unfocused')
a = colorbar;
ylabel(a,'Pressure (MPa)','FontSize',16,'Rotation',90);








