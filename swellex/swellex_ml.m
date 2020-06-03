%Read in data
data = sioread('S5_data.sio',1,80*60*1500,[1:21]);
FS = 1500;

%% Get SCM 

% Define variables
N = 21;
NFFT = 12;
window = hanning(512);
overlap = 0;

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

f1 = 108.5;
f2 = 109.5;
%9m dpeth: 109 163 232 385
%54m depth:112 148 201 283
w = exp(-1i*2*pi*(f2-f1)/(NFFT*FS));
a = exp(1i*2*pi*f1/FS);
flist = linspace(f1,f2,NFFT)';


ts_f_mat = zeros(NFFT,N,num_window);
for l = 1:num_window
    ts_f_mat(:,:,l) = (1/(sqrt(FS)*norm(window(:,1),2)))*sqrt(2)*czt(window.*data(l*window_start-window_start+1:l*window_start-window_start+win_len,:),NFFT,w,a);
    t(l) = ((l+1)*window_start-window_start+1)/FS;
end

% Calculate Sn_mat for plane wave noise
num_ss = 25;

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
clear cov_mat_norm
for k = 1:size(cov_mat,3)
    cov_mat_norm(:,:,k) = cov_mat(:,:,k)./real(trace(cov_mat(:,:,k)));
    [ri,ci] = find(~isfinite(cov_mat_norm(:,:,k)));
    if ~isempty(ri)
        cov_mat_norm(ri,ci,k) = 0+0i;
    end
end

%% Write to file

features = zeros(size(cov_mat_norm,3),size(cov_mat_norm,2)*(size(cov_mat_norm,2)+1));

for k = 1:size(cov_mat_norm,3)
    temp = [];
    for i = 1:size(cov_mat_norm,1)
        for j = i:size(cov_mat_norm,2)
            re = real(cov_mat_norm(i,j,k));
            im = imag(cov_mat_norm(i,j,k));
            
            temp = [temp re im];
            
            
        end
    end
    
    features(k,:) = temp;
end

dlmwrite('vec_mat_features_swellex_shallow_109hz2.csv',features,'precision',6)