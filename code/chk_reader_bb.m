%% USE THIS

array_size = 32;
%prefix = '/Users/Rui/Desktop/temp/';
prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/ICEX_src_newssp/chk_files_0.01intbb/';
%prefix = '/Users/Rui/Desktop/sidex_ML/example/chk_files/';
directory = dir([prefix '*.chk']);

oasn_cov = zeros(array_size,array_size,length(directory),11);

labels = zeros(length(directory),1);

for k = 1:length(directory)
    k
    filename = [prefix directory(k).name];
    fileID = fopen(filename);
    C = textscan(fileID,'%*s%s%s%s%*s%*s%*s','HeaderLines',array_size+2);
    
    for n = 1:11
        num = zeros(1086,1);
        re = zeros(1086,1);
        im = zeros(1086,1);
        for i = 1093*(n-1)+8:1093*n
            num(i-(1093*(n-1)+7)) = str2double(C{1,1}(i));
            re(i-(1093*(n-1)+7)) = str2double(C{1,2}(i));
            im(i-(1093*(n-1)+7)) = str2double(C{1,3}(i));
        end

        keep = ~isnan(num) & (floor(num) == num);
        re = re(keep);
        im = im(keep);

        data = complex(re,im);

        counter = 1;
        for i = 1:array_size
            for j = i:array_size
                oasn_cov(i,j,k,n) = data(counter);

                if i ~= j
                    oasn_cov(j,i,k,n) = conj(data(counter));
                end

                counter = counter + 1;
            end
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

acc = 0.5;
labels_c = round(labels/acc)*acc;

%% Normalization
oasn_cov_norm = zeros(array_size,array_size,length(directory),11);
for f = 1:11
    for k = 1:length(directory)
        oasn_cov_norm(:,:,k,f) = oasn_cov(:,:,k,f)./real(trace(oasn_cov(:,:,k,f)));
        [ri,ci] = find(~isfinite(oasn_cov_norm(:,:,k,f)));
        if ~isempty(ri)
            oasn_cov_norm(ri,ci,k,f) = 0+0i;
        end
    end
end


%% Add SNR

n = 32;
snr = -10;
oasn_cov_snr = [];

for mat = 1:size(oasn_cov,3)
    
    oasn_cov_snr_temp = awgn(oasn_cov(:,:,mat),2*snr,'measured');
    oasn_cov_snr(:,:,mat) = oasn_cov_snr_temp - diag(diag(oasn_cov_snr_temp)) + diag(abs(diag(oasn_cov_snr_temp)));
end

    
