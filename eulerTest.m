function [cost,temp] = eulerTest(windows)

load weather.mat

windowFixed = 0;        % are windows kept open;
heatingDisabled = 0;    % are we using active heating?
coolingDisabled = 0;    % are we using active cooling?

heatingPower = 5600;    % furnace power in watts
coolingPower = 1500;    % air conditioning power in watts
coolingEff = 3.513;     % ERR converted to W/W ratio (12 * 0.293)
costWatt = 6.09444e-8;   % electricity cost in dollars/watt


tAir = 294;
tOutside = airTemperatureK(1);

specAir = 1006;     % J / (kg*K)
specFloor = 960;    % J / (kg*K)
windowArea = windows;% m^2

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

bangCountWin = NaN(numSteps + 1,1);
bangCountWin(1) = 0;
windowOpen = NaN(numSteps + 1,1);
windowOpen(1) = 1;
bangCountHeat = NaN(numSteps + 1,1);
bangCountHeat(1) = 0;
heatingOn = NaN(numSteps + 1,1);
heatingOn(1) = 0;
bangCountCool = NaN(numSteps + 1,1);
bangCountCool(1) = 0;
coolingOn = NaN(numSteps + 1,1);
coolingOn(1) = 0;
heatingWatts = NaN(numSteps + 1,1);
heatingWatts(1) = 0;
coolingWatts = NaN(numSteps + 1,1);
coolingWatts(1) = 0;

U = zeros(size(T)); % air energies
U(1) = temperatureToEnergy(tAir, massAir, specAir);
insideT = zeros(size(T)); % air temperatures
F = zeros(size(T)); % floor energies
F(1) = temperatureToEnergy(tAir, massFloor, specFloor);
floorT = zeros(size(T)); % floor temperatures
C = zeros(size(T)); %Cost of heating/cooling

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
    % how much we heat or cool in watts
    heatingWatts(i) = (heatingOn(i)*heatingPower);
    coolingWatts(i) = (coolingOn(i)*coolingPower*coolingEff); 
     
    % convert W to J
    dudt = heatLost(i) * dt * 86400;
    dsdt = solarRadiation(i) * windowArea * dt * 86400;
    dfdt = floorConvection(i) * dt * 86400;
    dcdt = floorLost(i) * dt * 86400;
    dpdt = (heatingWatts(i) + (coolingWatts(i) / coolingEff))...
        * costWatt * 86400 * dt;
    dmdt = (heatingWatts(i) - coolingWatts(i)) * 86400 * dt;
    
    T(i+1) = T(i) + dt;
    % if windows stay open
    if windowFixed
        windowOpen(i+1) = 1;
    % close windows if it's already hot
    elseif (((insideT(i) > 296) | (airTemperatureK(i) > 294))...
            & (windowOpen(i) == 1))
        windowOpen(i+1) = 0;
        bangCountWin(i+1) = bangCountWin(i) + 1;
    % if it's cold open the windows
    elseif (((insideT(i) < 294) & (airTemperatureK(i) < 295))...
            & (windowOpen(i) == 0));
        windowOpen(i+1) = 1;
        bangCountWin(i+1) = bangCountWin(i) + 1;
    else
        windowOpen(i+1) = windowOpen(i);
        bangCountWin(i+1) = bangCountWin(i);
    end
    
    %don't do heating if it's disabled
    if heatingDisabled
        heatingOn(i+1) = 0;
    elseif ((insideT(i) > 294.5) & (heatingOn(i) ~= 0))
        heatingOn(i+1) = 0;
        bangCountHeat(i+1) = bangCountHeat(i) + 1;
    elseif ((insideT(i) < 291) & (airTemperatureK(i) < 285)...
            & (heatingOn(i) ~= 1))
        heatingOn(i+1) = 1;
        bangCountHeat(i+1) = bangCountHeat(i) + 1;
    elseif ((insideT(i) < 293) & (heatingOn(i) ~= .25))
        heatingOn(i+1) = .5;
        bangCountHeat(i+1) = bangCountHeat(i) + 1;
    elseif ((insideT(i) < 294.5) & (heatingOn(i) ~= .125))
        heatingOn(i+1) = .125;
        bangCountHeat(i+1) = bangCountHeat(i) + 1;
    else
        heatingOn(i+1) = heatingOn(i);
        bangCountHeat(i+1) = bangCountHeat(i);
    end
        
    %don't do cooling if it's disabled
    if coolingDisabled
        coolingOn(i+1) = 0;
   elseif (insideT(i) > 297) & (coolingOn(i) ~= .25)
        coolingOn(i+1) = .25;
        bangCountCool(i+1) = bangCountCool(i) + 1;
    elseif (insideT(i) > 297) & (coolingOn(i) ~= .5)
        coolingOn(i+1) = .5;
        bangCountCool(i+1) = bangCountCool(i) + 1;   
    elseif (insideT(i) < 297) & (coolingOn(i) ~= 0)
        coolingOn(i+1) = 0;
        bangCountCool(i+1) = bangCountCool(i) + 1;
    else
        coolingOn(i+1) = coolingOn(i);
        bangCountCool(i+1) = bangCountCool(i);
    end
        
    
    
    
    U(i+1) = U(i) + dudt + dfdt + dmdt;
    F(i+1) = F(i) + (dsdt*windowOpen(i)) - dfdt;
    C(i+1) = C(i) + dpdt;
end

% make same size for plotting
floorT(i+1) = floorT(i);
insideT(i+1) = insideT(i);
heatLost(i+1) = heatLost(i);
floorLost(i+1) = floorLost(i);
floorConvection(i+1) = floorConvection(i);
airTemperatureK(i+1) = airTemperatureK(i);
heatingWatts(i+1) = heatingWatts(i);
coolingWatts(i+1) = coolingWatts(i);

% data = energyToTemperature(U, massAir, specAir);
cost = C(i);
temp = insideT;
end