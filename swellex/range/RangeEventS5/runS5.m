%
% M-file to compute range from Sproul to each array location
% for duration of Event S5
%

% set up each of the 4 array locations
VLA = [32 + 40.254/60. 117 + 21.620/60.];
TLA = [32 + 40.222/60. 117 + 21.542/60.];
HLAN= [32 + 39.24/60.  117 + 21.72/60.];
HLAS= [32 + 37.66/60.  117 + 21.41/60.];
%
%
% read in Event S5 Sproul gps data 
%
S5 = load('EventS5.txt');
%
% micro mariner time is 1 minute and 3 seconds behind GPS time
%   1 + 3/60 = 1.05 mins correction needs to be added 
% since only have minute accuracy in data will only correct by 1 min.
for k = 1:length(S5),
   S5(k,3) = S5(k,3) + 1;
   if ( S5(k,3) >= 60 ) 
        S5(k,3) = S5(k,3) -60;
        S5(k,2) = S5(k,2) + 1;
        if ( S5(k,2) >= 24 )
           S5(k,2) = S5(k,2) -24;
           S5(k,1) = S5(k,1) + 1;
        end
    end
end         

S5Lat = S5(:,4)+S5(:,5)/60.;
S5Lon = S5(:,6)+S5(:,7)/60.;

% compute range to VLA
VLAlat = ones(length(S5),1)*VLA(1);
VLAlon = ones(length(S5),1)*VLA(2);
S5d = distance(VLAlat,VLAlon,S5Lat,S5Lon,'degrees');
VLAS5km = deg2km(S5d);
%
% compute range to TLA
TLAlat = ones(length(S5),1)*TLA(1);
TLAlon = ones(length(S5),1)*TLA(2);
S5d = distance(TLAlat,TLAlon,S5Lat,S5Lon,'degrees');
TLAS5km = deg2km(S5d);
%
% compute range to HLA North
HLANlat = ones(length(S5),1)*HLAN(1);
HLANlon = ones(length(S5),1)*HLAN(2);
S5d = distance(HLANlat,HLANlon,S5Lat,S5Lon,'degrees');
HLANS5km = deg2km(S5d);
%
% compute range to HLA South
HLASlat = ones(length(S5),1)*HLAS(1);
HLASlon = ones(length(S5),1)*HLAS(2);
S5d = distance(HLASlat,HLASlon,S5Lat,S5Lon,'degrees');
HLASS5km = deg2km(S5d);

%
% generate a time line in minutes since start of event
time  = S5(:,1)*1440 + S5(:,2)*60 +S5(:,3);
start = S5(1,1)*1440 + S5(1,2)*60 +S5(1,3);
tline = (time - ones(length(time),1)*start);

%  make a plot showing ranges to each array
%    first plot tic marks every 5 mins
tl2 = tline([1 6 11 15:5:77]);
plot(tl2,VLAS5km([1 6 11 15:5:77]),'+',tl2,TLAS5km([1 6 11 15:5:77]),'x',tl2,HLANS5km([1 6 11 15:5:77]),'^',tl2,HLASS5km([1 6 11 15:5:77]),'v')
legend('VLA','TLA','HLA North','HLA South')
hold on
% then plot every minute to have a smooth line
plot(tline,VLAS5km,tline,TLAS5km,tline,HLANS5km,tline,HLASS5km)
title('SWellEx96 Event S5  Range to Sproul from each array  (tic every 5 min)')
xlabel('Time (min)')
ylabel('Range (km)')
grid on
orient landscape
print('-dpsc','EventS5.ps')

% Save a full range information to text file
fid1 = fopen('SproulToVLA.S5.txt','w');
fid2 = fopen('SproulToTLA.S5.txt','w');
fid3 = fopen('SproulToHLAN.S5.txt','w');
fid4 = fopen('SproulToHLAS.S5.txt','w');
fprintf(fid1,' Jday Time  Duration Range(km)\n');
fprintf(fid2,' Jday Time  Duration Range(km)\n');
fprintf(fid3,' Jday Time  Duration Range(km)\n');
fprintf(fid4,' Jday Time  Duration Range(km)\n');
for k = 1:length(S5),
  fprintf(fid1,'  %03d %02d:%02d   %2.0f      %5.3f\n', S5(k,1),S5(k,2),S5(k,3),tline(k),VLAS5km(k));
  fprintf(fid2,'  %03d %02d:%02d   %2.0f      %5.3f\n', S5(k,1),S5(k,2),S5(k,3),tline(k),TLAS5km(k));
  fprintf(fid3,'  %03d %02d:%02d   %2.0f      %5.3f\n', S5(k,1),S5(k,2),S5(k,3),tline(k),HLANS5km(k));
  fprintf(fid4,'  %03d %02d:%02d   %2.0f      %5.3f\n', S5(k,1),S5(k,2),S5(k,3),tline(k),HLASS5km(k));
end
fclose(fid1);
fclose(fid2);
fclose(fid3);
fclose(fid4);
