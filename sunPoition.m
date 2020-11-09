function sunPoition()

twoPi = 2 * pi;
deg2rad = pi / 180;
 
% All the days we wan't to compute this for. I've hardcoded it for 2019,
% but it would be easy to make this work for all years.
timeInterval = [1:1/288:365];

% Convert to Julian date then almanac input. The offset is for the
% beginning of 2019. Our first observation is five minutes later. Each five
% minute interval is 1/288 days.
julianDate = timeInterval + 6939.50000;  
    
%Don't have to worry about negatives after 2000.

% Ecliptic coordinates.
    
% Mean longitude.
meanLongitude = mod((280.460 + .9856474 * julianDate), 360);

% Mean anomaly
meanAnomaly = mod((357.528 + .9856003 * julianDate), 360) * deg2rad;
    
% Ecliptic longitude and obliquity of ecliptic
eclipticLongitude = meanLongitude + 1.915 * sin(meanAnomaly)...
    + 0.020 * sin(2 * meanAnomaly);
eclipticLongitude = mod(eclipticLongitude, 360) * deg2rad;
% this is almost meaningless
eclipticObliquity = 23.439 - 0.0000004 * julianDate * deg2rad;

% Celestial coordinates

% Right ascension and declination
% this is not affecting the whole matrix yet
num = cos(eclipticObliquity) .* sin(eclipticLongitude);
den = cos(eclipticLongitude);
rightAscension = atan(num ./ den);
%     ra[den < 0] <- ra[den < 0] + pi
%     ra[den >= 0 & num < 0] <- ra[den >= 0 & num < 0] + twopi
declination = asin(sin(eclipticObliquity) .* sin(eclipticLongitude));
 
% Local coordinates

% Another time system, who knew! Greenwich mean sidereal time.
%     gmst = 6.697375 + .0657098242 * time + hour
%     gmst <- gmst %% 24
%     gmst[gmst < 0] <- gmst[gmst < 0] + 24.
% 
%     # Local mean sidereal time
%     lmst <- gmst + long / 15.
%     lmst <- lmst %% 24.
%     lmst[lmst < 0] <- lmst[lmst < 0] + 24.
%     lmst <- lmst * 15. * deg2rad
% 
%     # Hour angle
%     ha <- lmst - ra
%     ha[ha < -pi] <- ha[ha < -pi] + twopi
%     ha[ha > pi] <- ha[ha > pi] - twopi
% 
%     # Latitude to radians
%     lat <- lat * deg2rad
% 
%     # Azimuth and elevation
%     el <- asin(sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(ha))
%     az <- asin(-cos(dec) * sin(ha) / cos(el))
% 
%     # For logic and names, see Spencer, J.W. 1989. Solar Energy. 42(4):353
%     cosAzPos <- (0 <= sin(dec) - sin(el) * sin(lat))
%     sinAzNeg <- (sin(az) < 0)
%     az[cosAzPos & sinAzNeg] <- az[cosAzPos & sinAzNeg] + twopi
%     az[!cosAzPos] <- pi - az[!cosAzPos]
% 
%     # if (0 < sin(dec) - sin(el) * sin(lat)) {
%     #     if(sin(az) < 0) az <- az + twopi
%     # } else {
%     #     az <- pi - az
%     # }
% 
% 
%     el <- el / deg2rad
%     az <- az / deg2rad
%     lat <- lat / deg2rad
% 
%     return(list(elevation=el, azimuth=az))

end