%% Inputs
meas_time = 2; % s
pos = [0, 0]; % mm; >= 0

%% Init DAQ and acquire data
dq = daq("ni");
dq.Rate = 8000;
addinput(dq, "Dev1", "ai0", "Voltage"); % hydrophone
addinput(dq, "Dev1", "ai4", "Voltage"); % control (generator)

data = read(dq, round(meas_time * dq.Rate));

%% Preprocess and store
dataset.data = [seconds(data.Time), data.Variables];
dataset.srate = dq.Rate;
dataset.position = pos;

thr_voltage = 0.5; % V
idx = find(dataset.data(:, 3) >= thr_voltage, 1);
dataset.data = dataset.data(idx:end, :); % Discard data before onset

save(append(num2str(pos), '.mat'), 'dataset');


