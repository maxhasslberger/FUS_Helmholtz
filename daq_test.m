dq = daq("ni");
dq.Rate = 1000;
addinput(dq, "Dev1", "ai0", "Voltage");
% addinput(dq, "Dev1", "ai1", "Voltage");
% addinput(dq, "Dev1", "ai2", "Voltage");
% addinput(dq, "Dev1", "ai3", "Voltage");
addinput(dq, "Dev1", "ai4", "Voltage");
% addinput(dq, "Dev1", "ai5", "Voltage");
% addinput(dq, "Dev1", "ai6", "Voltage");
% addinput(dq, "Dev1", "ai7", "Voltage");

% matrixdata = read(dq, 2 * dq.Rate, "OutputFormat", "Matrix")
data = read(dq, round(2 * dq.Rate));
plot(data.Time, data.Variables);
% legend('0', '1', '2', '3', '4', '5', '6', '7') 
ylabel("Voltage (V)")
grid on
ylim([-0.5, 0.5])