%% Input param
clear;
path = 'Data/Instrument_Studio/skull_meas/';
channel = 1; % oscilloscope channel
dx = 2.0 * 1e-3; % m
% offset = [0.0 * 1e-3, 0.0 * 1e-3]; % m
center_frq = 2.0; % MHz -> Transducer frq
amp_flag = 0; % amplifier used between hydrophone - DAQ?

% LUT for hydrophone and amplifiers
lut = [0.5, 2.0, 15.0; ... % MHz
    530.9, 530.9, 530.9; ... % NP-2519 amplifier -> ~54.5 dB (small signal)-> ~ 60 dB for very small signals!
    188.4 * 1e-9, 158.5 * 1e-9, 105.9 * 1e-9]; % Onda HNR-0500 hydrophone (V/Pa) -> [~-254.5, ~-256.0, ~-259.5] dB

% dim = 2;
%% Load and merge files
folders = dir(path);
folders = folders(3:end); % skip . and ..
signal = NaN(length(folders));

avg_elements = 10;

for dis = 1:length(folders)
    ext_path = strcat(path, folders(dis).name, '/');
    disp(strcat('Processing: ', ext_path))
    files = dir(strcat(ext_path, '*.csv'));
    
    vert_idx = 1;
    for cond = 1:length(files)
        if ~contains(files(cond).name, 'Waveform Data')
            continue;
        end
        %% Compute representative position value
%         % Std encoding
%         data = importdata(strcat(ext_path, files(vert).name));
        % Instrument studio encoding
%         [~,~,data] = xlsread(strcat(ext_path, files(vert).name));
%         data = [data{7:end, 1}];
        data = readmatrix(strcat(ext_path, files(cond).name));
        
        % Determine amplitude and store
        max_avg = +mean(maxk(findpeaks(+data), avg_elements));
        min_avg = -mean(maxk(findpeaks(-data), avg_elements));
        datapoint = (max_avg - min_avg) / 2;
        
        signal(vert_idx, dis) = datapoint;
        vert_idx = vert_idx + 1;
    end
end


%% Process
% Discard NaN rows and cols
signal(:, all(isnan(signal), 1)) = [];
signal(all(isnan(signal), 2), :) = [];

signal(1, 1) = 0; % Cond. 1 at distance 0 not measured!

% Pressure conversion
lut_idx = find(lut(1, :) == center_frq);
pressure = signal * lut(2, lut_idx)^amp_flag / lut(3, lut_idx); % Voltage signal converted to Pa

%% Plot
xlabel('z (mm)');
ylabel('Pressure (MPa)');
title('SU-126 (2 MHz) - coupling cone');








