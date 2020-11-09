function weather()
% this function processes a set of data from Kingston, Rhode Island

% load data as a table
dataTable = readtable('CRNS0101-05-2019-RI_Kingston_1_NW.txt');

% put data in matrices for easy access
lstDate = dataTable.Var4; % YYYYMMDD
lstTime = dataTable.Var5; % HHmm
airTemperatureC = dataTable.Var9; % C
airTemperatureK = airTemperatureC + 273.15; % K
solarRadiation = dataTable.Var11; % W/m^2

% save our matrices
save('weather.mat');
end