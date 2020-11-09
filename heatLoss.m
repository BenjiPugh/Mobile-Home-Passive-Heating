function rate = heatLoss(indoorT, outdoorT)
    %Using refrences for standard mobile homes in the northeast, 40 K*m^2/W
    %is a recommended standard
    rVal = 40;      %K*m^2/W
    
    %Standard Mid-Sized manufactured home is 14x56x13.5ft or
    %4.27x17.06x4.11m
    area = 7,387;   %m^2
    dUdt = (outdoorT - indoorT) * area / rVal;      %in Watts
    rate = -dUdt;
end