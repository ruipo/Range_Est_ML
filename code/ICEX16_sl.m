%% Load Data
FS = 12000; 
NUM_SAMPLES = FS*2;     
NUM_CHANNELS = 32;

 
% Set Path to DATA
prefix = '/Volumes/icex6/ICEX_UNCLASS/ICEX16/macrura/2016-03-13/DURIP/DURIP_20160313T055853/';
%prefix = '/Volumes/icex6/ICEX_UNCLASS/ICEX16/macrura/2016-03-14_andbefore/DURIP/DURIP_20160314T002324/';
 
directory = dir([prefix 'ACO0000*.DAT']);

first_file = 2000+0*1800;
last_file = first_file + 1800;
 
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

%for icex hourly and depths, windowlen = 16384, overlap = 0.5, num_ss = 15,
%dt = 10.24 sec
%for icex test, windowlen = 8192, overlap = 0.5, num_ss = 32 (full rank),
%dt = 10.92 sec

% Define variables
N = 32;
NFFT = 512;
window = hanning(8192);
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

%% Normalization
for k = 1:size(cov_mat,3)
    cov_mat(:,:,k) = cov_mat(:,:,k)./trace(cov_mat(:,:,k));
end

%% Write to file

features = zeros(size(cov_mat,3),size(cov_mat,2)*(size(cov_mat,2)+1));

for k = 1:size(cov_mat,3)
    temp = [];
    for i = 1:size(cov_mat,1)
        for j = i:size(cov_mat,2)
            re = real(cov_mat(i,j,k));
            im = imag(cov_mat(i,j,k));
            
            temp = [temp re im];
            
            
        end
    end
    
    features(k,:) = temp;
end

dlmwrite('vec_mat_features_icex_src_icex16_test.csv',features,'precision',6)
