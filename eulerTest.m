load weather.mat

tAir = 294;
tOutside = airTemperatureK(1);
specAir = 1006;     % J / (kg*K)
specFloor = 960;    % J / (kg*K)
windowArea = 16;     % m^2

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

bangCount = NaN(numSteps + 1,1);
bangCount(1) = 0;
windowOpen = NaN(numSteps + 1,1);
windowOpen(1) = 1;

U = zeros(size(T)); % air energies
U(1) = temperatureToEnergy(tAir, massAir, specAir);
insideT = zeros(size(T)); % air temperatures
F = zeros(size(T)); % floor energies
F(1) = temperatureToEnergy(tAir, massFloor, specFloor);
floorT = zeros(size(T)); % floor temperatures

heatLost = NaN(numSteps + 1,1); % heat through walls (for plotting)
floorLost = NaN(numSteps + 1,1); % heat through walls (for plotting)
floorConvection = NaN(numSteps + 1,1); % heat from floor (for plotting)
for i = 1:numSteps
    % temperatures of floor
    floorT(i) = energyToTemperature(F(i), massFloor, specFloor);
    % temperature inside
    insideT(i) = energyToTemperature(U(i), massAir, specAir);
    % heat through walls in watts (J/s)
    heatLost(i) = heatLoss(insideT(i), airTemperatureK(i));
    floorLost(i) = heatLoss(floorT(i), airTemperatureK(i));
    % heat to air in watts
    floorConvection(i) = floorToAir(floorT(i), insideT(i));
    % convert W to J
    dudt = heatLost(i) * dt * 86400;
    dsdt = solarRadiation(i) * windowArea * dt * 86400;
    dfdt = floorConvection(i) * dt * 86400;
    dcdt = floorLost(i) * dt * 86400;
    T(i+1) = T(i) + dt;
    % close windows if it's already hot
    if (((insideT(i) > 296) | (airTemperatureK(i) > 294))...
            & (windowOpen(i) == 1))
        windowOpen(i+1) = 0;
        bangCount(i+1) = bangCount(i) + 1;
    % if it's cold open the windows
    elseif (((insideT(i) < 294) & (airTemperatureK(i) < 295))...
            & (windowOpen(i) == 0));
        windowOpen(i+1) = 1;
        bangCount(i+1) = bangCount(i) + 1;
    else
        windowOpen(i+1) = windowOpen(i);
        bangCount(i+1) = bangCount(i);
    end
    
    U(i+1) = U(i) + dudt + dfdt;
    F(i+1) = F(i) + (dsdt*windowOpen(i)) - dfdt + dcdt;  
end

% make same size for plotting
floorT(i+1) = floorT(i);
insideT(i+1) = insideT(i);
heatLost(i+1) = heatLost(i);
floorLost(i+1) = floorLost(i);
floorConvection(i+1) = floorConvection(i);

% data = energyToTemperature(U, massAir, specAir);