load weather.mat

tAir = 294;
tOutside = airTemperatureK(1);
specAir = 1006;     %Joules/(kg*K)
windowArea = 1;     %m^2

densAir = 1.225;    %kg / m^3
volumeAir = 299;    %m^3 Standard volume of midsized manufactured home (4.27x17.06x4.11)
massAir = densAir * volumeAir;  %kg

t0 = 0;
tend = 365;      %days

dt = 1/(24*12);

numSteps = (tend - t0) / dt;
T = zeros(numSteps + 1, 1);

U = zeros(size(T));
U(1) = temperatureToEnergy(tAir, massAir, specAir);

heatLost = NaN(numSteps + 1,1);
for i = 1:numSteps
    % heat lost in watts (J/s)
    heatLost(i) = heatLoss(energyToTemperature(U(i), massAir, specAir), ...
        airTemperatureK(i));
    % convert W to J
    dudt = heatLost(i)*dt*86400;
    dsdt = solarRadiation(i) * windowArea * dt *86400;
    T(i+1) = T(i) + dt;
    U(i+1) = U(i) + dudt + dsdt;
end

energyToTemperature(U(numSteps), massAir, specAir)

data = energyToTemperature(U, massAir, specAir);
plot(T, data)