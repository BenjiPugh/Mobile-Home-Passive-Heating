tAir = 294;
tOutside = 278;
specAir = 1006;     %Joules/(kg*K)

densAir = 1.225;    %kg / m^3
volumeAir = 299;    %m^3 Standard volume of midsized manufactured home (4.27x17.06x4.11)
massAir = densAir * volumeAir;  %kg

t0 = 0;
tend = 1;      %days

dt = 1/(24*12);

numSteps = (tend - t0) / dt;
T = zeros(numSteps + 1, 1);

U = zeros(size(T));
U(1) = temperatureToEnergy(tAir, massAir, specAir);
for i = 1:numSteps
    % heat lost in watts (J/s)
    heatLost = heatLoss(energyToTemperature(U(i), massAir, specAir), tOutside);
    % convert W to W h
    dudt = heatLost*dt*3600;
    T(i+1) = T(i) + dt;
    U(i+1) = U(i) + dudt;
end

energyToTemperature(U(numSteps), massAir, specAir)

Data = energyToTemperature(U, massAir, specAir);
plot(T, Data)


    