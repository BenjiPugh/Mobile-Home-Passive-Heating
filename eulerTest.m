tAir = 294;
tOutside = 278;
specAir = 1006;     %Joules/(kg*K)

densAir = 1.225;    %kg / m^3
volumeAir = 299;    %m^3 Standard volume of midsized manufactured home (4.27x17.06x4.11)
massAir = densAir * volumeAir;  %kg

t0 = 0;
tend = 86400;      %seconds

dt = 300;

numSteps = (tend - t0) / dt;
T = zeros(numSteps + 1, 1);

U = zeros(size(T));
U(1) = temperatureToEnergy(tAir, massAir, specAir);
for i = 1:numSteps
    % heat lost in watts (J/s)
    heatLost = heatLoss(energyToTemperature(U(i), massAir, specAir), tOutside);
    % convert W to 
    dudt = heatLost*dt;
    T(i+1) = T(i) + dt;
    U(i+1) = U(i) + dudt;
end

energyToTemperature(U(numSteps), massAir, specAir)

data = energyToTemperature(U, massAir, specAir);
plot(T, data)


    