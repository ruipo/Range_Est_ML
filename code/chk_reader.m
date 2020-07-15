% read in .chk files from oasn and generate the covariance matrices from
% each file in the directory

%% classfication

array_size = 32;
%prefix = '/Users/Rui/Desktop/chk_files/';
prefix = '/Users/Rui/Desktop/ML/ICEX_src_newssp/chk_files_0.1intbb/';
directory = dir([prefix '*.chk']);

xlsfiles={directory.name};
xlsfiles_num = [];

for f = 1:length(xlsfiles)
    
    if ~isnan(str2double(xlsfiles{1,f}(1:4)))
        xlsfiles_num(f) = str2double(xlsfiles{1,f}(1:4));
    else
        xlsfiles_num(f) = str2double(xlsfiles{1,f}(1:3));
    end
    
end
        
[~,idx]=sort(xlsfiles_num);
sorted_directory=directory(idx);

oasn_cov = zeros(array_size,array_size,length(sorted_directory));

for k = 1:length(sorted_directory)
    k
    filename = [prefix sorted_directory(k).name];
    fileID = fopen(filename);
    C = textscan(fileID,'%*s%s%s%s%*s%*s%*s','HeaderLines',array_size+9);

    for i = 1:length(C{1,1})
        num(i) = str2double(C{1,1}(i));
        re(i) = str2double(C{1,2}(i));
        im(i) = str2double(C{1,3}(i));
    end

    keep = ~isnan(num) & (floor(num) == num);
    re = re(keep);
    im = im(keep);

    data = complex(re,im);

    counter = 1;
    for i = 1:array_size
        for j = i:array_size
            oasn_cov(i,j,k) = data(counter);

            if i ~= j
                oasn_cov(j,i,k) = conj(data(counter));
            end

            counter = counter + 1;
        end
    end
    
    fclose(fileID);
end

%% USE THIS

array_size = 21;
%prefix = '/Users/Rui/Desktop/temp/';
%prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/ICEX_src_newssp/chk_files_0.01intbb/';
%prefix = '/Users/Rui/Desktop/swellex/shallow/param3/221m/mid_ssp/chk_files_221m/';
%prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/swellex/shallow/tests/test6_chk_files/';
prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/swellex/shallow/long_range/chk_files_0.01train_109hz_lr/';
directory = dir([prefix '*.chk']);

oasn_cov = zeros(array_size,array_size,length(directory));
labels = zeros(length(directory),1);

for k = 1:length(directory)
    k
    filename = [prefix directory(k).name];
    fileID = fopen(filename);
    C = textscan(fileID,'%*s%s%s%s%*s%*s%*s','HeaderLines',array_size+9);
    

    for i = 1:length(C{1,1})
        num(i) = str2double(C{1,1}(i));
        re(i) = str2double(C{1,2}(i));
        im(i) = str2double(C{1,3}(i));
    end

    keep = ~isnan(num) & (floor(num) == num);
    re = re(keep);
    im = im(keep);

    data = complex(re,im);

    counter = 1;
    for i = 1:array_size
        for j = i:array_size
            oasn_cov(i,j,k) = data(counter);

            if i ~= j
                oasn_cov(j,i,k) = conj(data(counter));
            end

            counter = counter + 1;
        end
    end
    
    %normalization
    %oasn_cov(:,:,k) = oasn_cov(:,:,k)./trace(oasn_cov(:,:,k));
    
    fclose(fileID);
    
    fileID = fopen(filename);
    L = textscan(fileID,'%s',1,'delimiter','\n', 'headerlines',array_size+5);
    templabel = str2double(L{1,1}{1,1}(1:12));
    labels(k) = templabel/1000;
    
    fclose(fileID);
end

acc = 0.1;
labels_c = round(labels/acc)*acc;

% Normalization
for k = 1:length(directory)
    oasn_cov_norm(:,:,k) = oasn_cov(:,:,k)./real(trace(oasn_cov(:,:,k)));
    [ri,ci] = find(~isfinite(oasn_cov_norm(:,:,k)));
    if ~isempty(ri)
        oasn_cov_norm(ri,ci,k) = 0+0i;
    end
end


%% Add SNR
% 
% n = 21;
% snr = 0;
% oasn_cov_snr = [];
% 
% for mat = 1:size(oasn_cov_norm,3)
%     
%     oasn_cov_snr_temp = awgn(oasn_cov_norm(:,:,mat),2*snr,'measured');
%     oasn_cov_snr(:,:,mat) = oasn_cov_snr_temp - diag(diag(oasn_cov_snr_temp)) + diag(abs(diag(oasn_cov_snr_temp)));
% end

snr = 10;
n = 32;
amp = trace(oasn_cov(:,:,900));
sigma2 = amp/(n*10^(snr/10));
noise = sqrt(sigma2 / 2) * (randn(1, n) + (1i * randn(1, n))).';
noise_mat = noise*noise';
oasn_cov_noise = oasn_cov + noise_mat;

for k = 1:length(directory)
    oasn_cov_snr(:,:,k) = oasn_cov_noise(:,:,k)./trace(oasn_cov_noise(:,:,k)); % normalized covariance matrices
end

    