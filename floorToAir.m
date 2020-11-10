function rate = floorToAir(floorT, insideT)

heatTransferAir = 10;                                   % W/(m^2*K)
area = 4.27 * 17.06;                                    % m^2
convectionResistance = (1 / heatTransferAir * area);    % poorly named
dUdt = (1 / convectionResistance) * (floorT - insideT); % Watts
rate = dUdt;
end