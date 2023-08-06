"# FUS_Helmholtz" 

## create_colorplot.m and plot_attenuation functions
To use these functions, Data (captured with the NI-USB 5133 oscilloscope) 
must be stored in separate folders (corr. to indiv. row indices). 
Each folder contains one 'Waveform Data' csv file for each column index. 
It is important that each folder contains the same
amount of 'Waveform Data' files (=> rows x cols image). Besides, data
must be captured in the same order across all rows (First measurement
spatially on the same column for every row measurement (=folder)).
Distance between subsequent columns and rows (=dx) shall remain 
unchanged.

For create_colorplot.m: If the files are encoded in an old format of the NI-USB oscilloscope, use 
the create_colorplot_oldFormat.m function instead.

## NI_DAQ and rigol functions
Not being updated anymore as the NI_DAQ sampling rate is insufficient for FUS purposes and NI-USB 5133 Data capturing is more handy.
