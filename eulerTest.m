load weather.mat

tAir = 294;
tOutside = airTemperatureK(1);
specAir = 1006;     % J / (kg*K)
specFloor = 960;    % J / (kg*K)
windowArea = 4;     % m^2

densAir = 1.225;    % kg / m^3
volumeAir = 299;    % m^3 Standard volume of midsized manufactured home
massAir = densAir * volumeAir;  % kg
densFloor = 2400;   % kg / m^3
volumeFloor = 4.27 * 17.06 * 0.2; % arbitrary thickness
massFloor = densFloor * volumeFloor; % kg, assuming 

t0 = 0;
tend = 365;         % days

dt = 1/(24*12);     % our dataset has readings every five minutes

numSteps = (tend - t0) / dt; % how many time steps we are simulating
T = zeros(numSteps, 1); % matrix of timesteps. important for plotting

U = zeros(size(T)); % air energies
U(1) = temperatureToEnergy(tAir, massAir, specAir);
F = zeros(size(T)); % floor energies
F(1) = temperatureToEnergy(tAir, massFloor, specFloor);

heatLost = NaN(numSteps,1); % heat through walls (for plotting)
floorConvection = NaN(numSteps,1); % heat from floor (for plotting)
for i = 1:numSteps - 1
    % temperatures of floor
    floorT = energyToTemperature(F(i), massFloor, specFloor);
    % temperature inside
    insideT = energyToTemperature(U(i), massAir, specAir);
    % heat through walls in watts (J/s)
    heatLost(i) = heatLoss(insideT, airTemperatureK(i));
    % heat to air in watts
    floorConvection(i) = floorToAir(floorT, insideT);
    % convert W to J
    dudt = heatLost(i) * dt * 86400;
    dsdt = solarRadiation(i) * windowArea * dt * 86400;
    dfdt = floorConvection(i) * dt * 86400;
    T(i+1) = T(i) + dt;
    U(i+1) = U(i) + dudt + dfdt;
    F(i+1) = F(i) + dsdt;
end

data = energyToTemperature(U, massAir, specAir);
clf; hold on;
plot(T, data - airTemperatureK)