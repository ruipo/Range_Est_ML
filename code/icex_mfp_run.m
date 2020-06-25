
%% Read in replica vectors

prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/mfp/rpo_files/';
filename1 = [prefix '0.01int_mfp_reps1.txt'];
filename2 = [prefix '0.01int_mfp_reps2.txt'];
filenames = [filename1; filename2];

    
fileID = fopen(filenames(1,:));
C = textscan(fileID,'%s%s%s%s%s%s%s%s','HeaderLines',46);

temp = zeros(length(C{1,7})-7,1);
for j = 1:length(C{1,7})-7
    j
    temp(j,1) =  str2double(C{1,7}{j,1}) + 1i*str2double(C{1,8}{j,1}(1:end-1));
end

rep1 = reshape(temp,[32,3701,3]); %array element X range X depth

fclose(fileID);

fileID = fopen(filenames(2,:));
C = textscan(fileID,'%s%s%s%s%s%s%s%s','HeaderLines',46);

temp = zeros(length(C{1,7})-7,1);
for j = 1:length(C{1,7})-7
    j
    temp(j,1) =  str2double(C{1,7}{j,1}) + 1i*str2double(C{1,8}{j,1}(1:end-1));
end

rep2 = reshape(temp,[32,1000,3]); %array element X range X depth

fclose(fileID);

rep_mat = [rep1 rep2]; % not normalized replica vectors

%% Load in ICEX Data
FS = 12000; 
NUM_SAMPLES = FS*2;     
NUM_CHANNELS = 32;

 
% Set Path to DATA
prefix = '/Volumes/icex6/ICEX_UNCLASS/ICEX16/macrura/2016-03-13/DURIP/DURIP_20160313T055853/';
%prefix = '/Volumes/icex6/ICEX_UNCLASS/ICEX16/macrura/2016-03-14_andbefore/DURIP/DURIP_20160314T002324/';
 
directory = dir([prefix 'ACO0000*.DAT']);

first_file = 16000;
last_file = 17000;
 
% Read DATA
aco_in = zeros(NUM_SAMPLES * (last_file-first_file), 32);
  
% Start looping over ACO*.DAT files
counter=0;
for i = first_file:last_file-1
 
    counter=counter+1;
    filename = [prefix directory(i).name];
    fid = fopen (filename, 'r', 'ieee-le');
 
    if (fid <= 0)
        continue;
    end
 
    % Read the single precision float acoustic data samples (in uPa)
    for j = 1:NUM_CHANNELS
        aco_in(((counter-1)*NUM_SAMPLES+1):(counter*NUM_SAMPLES),j) = fread (fid, NUM_SAMPLES, 'float32');
    end
     
    fclose (fid);
end

data = aco_in;
%data = [aco_in(1:10000000,:);aco_in(14000000:24000000,:);aco_in(28000000:38500000,:)];

timestamp = 1457848722.58 + first_file*2;
data_name = datestr ((timestamp / 86400) + datenum (1970,1,1), 31);


%% Get SCM 

% Define variables
N = 32;
NFFT = 512;
window = hanning(10240);
overlap = 0.5;

win_len = length(window);
t_end = size(data,1)/FS;

for m = 2:size(data,2)
    window = [window,window(:,1)];
end

% Format data
% data_len = 2^nextpow2(size(data,1));
% zero_len = data_len - size(data,1);
% zero_mat = zeros(zero_len,size(data,2));
% data = [data;zero_mat];

window_start = round(win_len-win_len*overlap);
num_window = round(size(data,1)/window_start)-2;
t = zeros(num_window,1);


% FFT Data

f1 = 800;
f2 = 900;
w = exp(-1i*2*pi*(f2-f1)/(NFFT*FS));
a = exp(1i*2*pi*f1/FS);
flist = linspace(f1,f2,NFFT)';


ts_f_mat = zeros(NFFT,N,num_window);
for l = 1:num_window
    ts_f_mat(:,:,l) = (1/(sqrt(FS)*norm(window(:,1),2)))*sqrt(2)*czt(window.*data(l*window_start-window_start+1:l*window_start-window_start+win_len,:),NFFT,w,a);
    t(l) = ((l+1)*window_start-window_start+1)/FS;
end

% Calculate Sn_mat for plane wave noise
num_ss = 32;

start = 0;

cov_mat = zeros(N,N,floor(num_window/num_ss));
for ii = 1:floor(num_window/num_ss)
    ii
    
    cov_mat_temp = zeros(N,N,num_ss);
    for jj = 1:num_ss
        ts_ff = squeeze(mean(ts_f_mat(:,:,start+jj),1));
        cov_mat_temp(:,:,jj) = (ts_ff.' * conj(ts_ff)); 
    end
    
    start = start + num_ss;
    cov_mat(:,:,ii) = mean(cov_mat_temp,3);
end

condlist = zeros(1,size(cov_mat,3));

for k = 1:size(cov_mat,3)
    cov_mat(:,:,k) = cov_mat(:,:,k)./trace(cov_mat(:,:,k));
    condlist(k) = cond(cov_mat(:,:,k));
end

%% Conventional MFP

[mfp_output] = mfp_conv(cov_mat,rep_mat);

mfp_avg = squeeze(mean(mfp_output,1)); 

dist = linspace(3,50,4701);
pred_distance = zeros(size(cov_mat,3),1);
for j = 1:size(mfp_avg,2)
    [~,arg] = max(abs(mfp_avg(:,j)));
    pred_distance(j) = dist(arg);
end

%% Plotting
M = movmean(pred_distance,44);
time = t(1:num_ss:end);
figure
plot(time(1:end-1),pred_distance,'b.','MarkerSize',10)
hold on
plot(time(20:end-21),M(20:end-20),'r','linewidth',2)
grid on
set(gca,'fontsize',20)
xlabel('Time (sec)')
ylabel('Range (Km)')
xlim([0 time(end)])
ylabel('Predicted Source Distance (Km)')
ylim([3 50])
legend('sample predictions','10-min moving avg.')
title('ICEX16 238m-depth MFP')

%%
pred_distance_all = [pred_distance_all;pred_distance];
%%
M = movmean(pred_distance_all(1:2252),44);
t_start = 1457852733;
dt = 13.6533;
timevec = linspace(0,length(pred_distance_all)*13.6533,length(pred_distance_all))+t_start;
timevecdate = datetime(timevec, 'convertfrom','posixtime');

figure
plot(timevecdate(1:2252),pred_distance_all(1:2252),'b.','MarkerSize',10)
hold on
plot(timevecdate(23:2252-22),M(23:end-22),'r','linewidth',2)
grid on
set(gca,'fontsize',20)
title('ICEX16 38m-depth MFP')
xlabel('Time (UTC)')
ylabel('Predicted Source Distance (Km)')
xlim([timevecdate(1) timevecdate(2252)])
ylim([3 50])
legend('sample predictions','10-min moving avg.')


