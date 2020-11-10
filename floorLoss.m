function rate = floorLoss(floorT, outdoorT)
%Using refrences for standard mobile homes in the northeast, 40 K*m^2/W
% is a recommended standard
rVal = 40;                                          % K*m^2/W
    
area = 4.27 * 17.06;                                % m^2
dUdt = (outdoorT - floorT) * area / rVal;       % in Watts
rate = dUdt;
end