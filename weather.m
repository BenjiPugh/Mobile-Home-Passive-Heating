function weather()
% this function processes a set of data from Kingston, Rhode Island

% load data as a table
dataTable = readtable('CRNS0101-05-2019-RI_Kingston_1_NW.txt');

% put data in matrices for easy access
lstDate = dataTable.Var4; % YYYYMMDD
lstTime = dataTable.Var5; % HHmm
airTemperatureC = dataTable.Var9; % C
missedTemperatureReadings = find(airTemperatureC == -9999);

% I know there is a smart way of doing this but a loop won't kill us.
for i=1:size(missedTemperatureReadings)
    index = missedTemperatureReadings(i);
    airTemperatureC(index) = airTemperatureC(index - 1);
end

airTemperatureK = airTemperatureC + 273.15; % K
solarRadiation = dataTable.Var11; % W/m^2
missedRadiationReadings = find(solarRadiation == -99999);

for i=1:size(missedRadiationReadings)
    index = missedRadiationReadings(i);
    solarRadiation(index) = solarRadiation(index - 1);
end

% save our matrices
save('weather.mat');
end