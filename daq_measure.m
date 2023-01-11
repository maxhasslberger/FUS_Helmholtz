%% Inputs
meas_time = 2; % s
pos = [0, 0]; % mm; >= 0
center_frq = 2.0; % MHz -> Transducer frq
amp_flag = 1; % amplifier used between hydrophone - DAQ?

% LUT for hydrophone and amplifiers
lut = [0.5, 2.0, 15.0; ... % MHz
    530.9, 530.9, 530.9; ... % NP-2519 amplifier -> ~54.5 dB (small signal)
    188.4 * 1e-9, 158,5 * 1e-9, 105.9 * 1e-9]; % Onda HNR-0500 hydrophone (V/Pa) -> [~-254.5, ~-256.0, ~-259.5] dB

%% Init DAQ and acquire data
dq = daq("ni");
dq.Rate = 8000;
addinput(dq, "Dev1", "ai4", "Voltage"); % hydrophone
addinput(dq, "Dev1", "ai5", "Voltage"); % input signal

data = read(dq, round(meas_time * dq.Rate));

%% Preprocess and store
dataset.time = seconds(data.Time);
dataset.data = data.Variables;
dataset.srate = dq.Rate;
dataset.position = pos;

discard = 100; % discard first samples
dataset.time = dataset.time(discard:end);
dataset.data = dataset.data(discard:end);

% Determine pressure values
lut_idx = find(lut(:, 1) == center_frq);
dataset.pressure = dataset.data * lut(lut_idx, 2)^amp_flag / lut(lut_idx, 3);

%% Export to mat-file
save(append(num2str(pos), '.mat'), 'dataset');


