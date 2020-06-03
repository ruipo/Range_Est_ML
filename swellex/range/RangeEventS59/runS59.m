%
% M-file to compute range from Sproul to each array location
% for duration of Event S59
%

% set up each of the 4 array locations
VLA = [32 + 40.254/60. 117 + 21.620/60.];
TLA = [32 + 40.222/60. 117 + 21.542/60.];
HLAN= [32 + 39.24/60.  117 + 21.72/60.];
HLAS= [32 + 37.66/60.  117 + 21.41/60.];
%
%
% read in Event S59 Sproul gps data 
%
S59 = load('EventS59.txt');
%
% micro mariner time is 1 minute and 3 seconds behind GPS time
%   1 + 3/60 = 1.05 mins correction needs to be added 
% since only have minute accuracy in data will only correct by 1 min.
for k = 1:length(S59),
   S59(k,3) = S59(k,3) + 1;
   if ( S59(k,3) >= 60 ) 
        S59(k,3) = S59(k,3) -60;
        S59(k,2) = S59(k,2) + 1;
        if ( S59(k,2) >= 24 )
           S59(k,2) = S59(k,2) -24;
           S59(k,1) = S59(k,1) + 1;
        end
    end
end         

S59Lat = S59(:,4)+S59(:,5)/60.;
S59Lon = S59(:,6)+S59(:,7)/60.;

% compute range to VLA
VLAlat = ones(length(S59),1)*VLA(1);
VLAlon = ones(length(S59),1)*VLA(2);
S59d = distance(VLAlat,VLAlon,S59Lat,S59Lon,'degrees');
VLAS59km = deg2km(S59d);
%
% compute range to TLA
TLAlat = ones(length(S59),1)*TLA(1);
TLAlon = ones(length(S59),1)*TLA(2);
S59d = distance(TLAlat,TLAlon,S59Lat,S59Lon,'degrees');
TLAS59km = deg2km(S59d);
%
% compute range to HLA North
HLANlat = ones(length(S59),1)*HLAN(1);
HLANlon = ones(length(S59),1)*HLAN(2);
S59d = distance(HLANlat,HLANlon,S59Lat,S59Lon,'degrees');
HLANS59km = deg2km(S59d);
%
% compute range to HLA South
HLASlat = ones(length(S59),1)*HLAS(1);
HLASlon = ones(length(S59),1)*HLAS(2);
S59d = distance(HLASlat,HLASlon,S59Lat,S59Lon,'degrees');
HLASS59km = deg2km(S59d);

%
% generate a time line in minutes since start of event
time  = S59(:,1)*1440 + S59(:,2)*60 +S59(:,3);
start = S59(1,1)*1440 + S59(1,2)*60 +S59(1,3);
tline = (time - ones(length(time),1)*start);

%  make a plot showing ranges to each array
%    first plot tic marks every 5 mins
max = length(S59);
tl2 = tline([1 6 11 15:5:max]);
plot(tl2,VLAS59km([1 6 11 15:5:max]),'+',tl2,TLAS59km([1 6 11 15:5:max]),'x',tl2,HLANS59km([1 6 11 15:5:max]),'^',tl2,HLASS59km([1 6 11 15:5:max]),'v')
legend('VLA','TLA','HLA North','HLA South',2)
hold on
% then plot every minute to have a smooth line
plot(tline,VLAS59km,tline,TLAS59km,tline,HLANS59km,tline,HLASS59km)
title('SWellEx96 Event S59  Range to Sproul from each array  (tic every 5 min)')
xlabel('Time (min)')
ylabel('Range (km)')
grid on
orient landscape
print('-dpsc','EventS59.ps')

% Save a full range information to text file
fid1 = fopen('SproulToVLA.S59.txt','w');
fid2 = fopen('SproulToTLA.S59.txt','w');
fid3 = fopen('SproulToHLAN.S59.txt','w');
fid4 = fopen('SproulToHLAS.S59.txt','w');
fprintf(fid1,' Jday Time  Duration Range(km)\n');
fprintf(fid2,' Jday Time  Duration Range(km)\n');
fprintf(fid3,' Jday Time  Duration Range(km)\n');
fprintf(fid4,' Jday Time  Duration Range(km)\n');
for k = 1:length(S59),
  fprintf(fid1,'  %03d %02d:%02d   %2.0f      %5.3f\n', S59(k,1),S59(k,2),S59(k,3),tline(k),VLAS59km(k));
  fprintf(fid2,'  %03d %02d:%02d   %2.0f      %5.3f\n', S59(k,1),S59(k,2),S59(k,3),tline(k),TLAS59km(k));
  fprintf(fid3,'  %03d %02d:%02d   %2.0f      %5.3f\n', S59(k,1),S59(k,2),S59(k,3),tline(k),HLANS59km(k));
  fprintf(fid4,'  %03d %02d:%02d   %2.0f      %5.3f\n', S59(k,1),S59(k,2),S59(k,3),tline(k),HLASS59km(k));
end
fclose(fid1);
fclose(fid2);
fclose(fid3);
fclose(fid4);
