%% Load and merge files 
dim = 2;
files = dir('*.mat');
data = [];
pos = [];
% pos = zeros(length(files), dim);

pos_ind = zeros(1, dim);
for i=1:length(files)
    tmp = load(files(i).name).dataset;
    
    new_pos = tmp.position > pos_ind;
    pos_ind = pos_ind + new_pos;
    new_inds = find(new_pos(1:end-1));
    pos_ind(new_inds + 1) = 0;
    
    pos(pos_ind(1) + 1, pos_ind(2) + 1, :) = tmp.position;
    data(pos_ind(1) + 1, pos_ind(2) + 1, :) = tmp.data(:, 2);
end
time = tmp.data(:, 1);

%% Process and Plot
peaks = max(abs(data), [], 3);
signal = rms(data, 3);

surf(pos(:, :, 1), pos(:, :, 2), signal, 'edgecolor', 'none');
view(2);
% pcolor(pos(:, :, 1), pos(:, :, 2), peaks);
% contourf(unique(pos(:, 1)), unique(pos(:, 2)), peaks);
colorbar



