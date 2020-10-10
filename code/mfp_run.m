
%% Read in replica vectors
clear rep_mat;
prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/mfp/rpo_files/';
% prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/swellex/shallow/long_range/mfp_repvecs/';
% prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/mfp/rpo_files/swellex/shallow/';
filename1 = [prefix '0.01int_mfp_reps1.txt'];
filename2 = [prefix '0.01int_mfp_reps2.txt'];
filenames = [filename1; filename2];
%filename1 = [prefix '109hz2_reps1.txt']; % For Swellex long range
%filename2 = [prefix '109hz2_reps2.txt'];
%filenames = [filename1; filename2];
%filename1 = [prefix '109hz2_reps.txt']; % For Swellex
%filenames = [filename1]; % For Swellex
    
fileID = fopen(filenames(1,:));
C = textscan(fileID,'%s%s%s%s%s%s%s%s%s','HeaderLines',35);

temp = zeros(length(C{1,7})-7,1);
for j = 1:length(C{1,7})-7
    temp(j,1) =  str2double(C{1,7}{j,1}) + 1i*str2double(C{1,8}{j,1}(1:end-1));
end

temp = temp(~isnan(temp));

rep1 = reshape(temp,[32,3701,3]); %array element X range X depth
%rep_mat = reshape(temp,[21,3001,3]); % For Swellex long range
%rep_mat = reshape(temp,[21,1001,3]); % For Swellex

fclose(fileID);

fileID = fopen(filenames(2,:));
C = textscan(fileID,'%s%s%s%s%s%s%s%s','HeaderLines',46);

temp = zeros(length(C{1,7})-7,1);
for j = 1:length(C{1,7})-7
    temp(j,1) =  str2double(C{1,7}{j,1}) + 1i*str2double(C{1,8}{j,1}(1:end-1));
end

rep2 = reshape(temp,[32,1000,3]); %array element X range X depth

fclose(fileID);

rep_mat = [rep1 rep2]; % not normalized replica vectors

%% Read in Covariance matrices

array_size = 32;
%prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/ICEX_src_newssp/example/';
prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/ICEX_src_newssp/chk_files_testh_0.01int/';
%prefix = '/Users/Rui/Desktop/swellex/shallow/tests/test9_chk_files/';
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
    
    fclose(fileID);
    
    fileID = fopen(filename);
    L = textscan(fileID,'%s',1,'delimiter','\n', 'headerlines',array_size+5);
    templabel = str2double(L{1,1}{1,1}(1:12));
    labels(k) = templabel/1000;
    
    fclose(fileID);
end

for k = 1:length(directory)
    oasn_cov_norm(:,:,k) = oasn_cov(:,:,k)./trace(oasn_cov(:,:,k)); % normalized covariance matrices
end

%% Add SNR
% 
% snr = -10;
% n = 32;
% amp = trace(oasn_cov(:,:,900));
% sigma2 = amp/(n*10^(snr/10));
% noise_mat = zeros(n,n,length(directory));
% for k = 1:length(directory)
%     noise = sqrt(sigma2 / 2) * (randn(1, n) + (1i * randn(1, n))).';
%     noise_mat(:,:,k) = noise*noise';
% end
% oasn_cov_noise = oasn_cov + noise_mat;
% 
% for k = 1:length(directory)
%     oasn_cov_snr(:,:,k) = oasn_cov_noise(:,:,k)./trace(oasn_cov_noise(:,:,k)); % normalized covariance matrices
% end

%% Conventional MFP

[mfp_output] = mfp_conv(oasn_cov_norm(:,:,2410),rep_mat(:,:,2));

mfp_avg = squeeze(mean(mfp_output,1)); 

%% dr MFP
[mfp_output] = mfp_dr(oasn_cov,rep_mat,0.75);

mfp_avg = squeeze(mean(mfp_output,1));

%% MLM MFP
[mfp_output] = mfp_mlm(oasn_cov,rep_mat);

mfp_avg = squeeze(mean(mfp_output,1));

%%
n = 50;
mfp_avg_mean = reshape(mfp_avg(1:end-1,:),n,[],1000);
mfp_avg_max = squeeze(max(mfp_avg_mean));

%% Plotting
dist_temp = linspace(3,50,4701);
dist = dist_temp;%cat(2,dist_temp,dist_temp,dist_temp,dist_temp,dist_temp,dist_temp,dist_temp,dist_temp,dist_temp,dist_temp,dist_temp);
act_distance = labels;
pred_distance = zeros(54,1);
    
acc = 0.1;
pred_dist_class = round(pred_distance./acc)*acc;
act_distance_class = round(act_distance./acc)*acc;

% calculate acc and mae
[sorted_act_distance,I] = sort(act_distance);
sorted_pred_distance = pred_distance(I);
sorted_pred_distance =sorted_pred_distance;
sorted_act_distance = sorted_act_distance;

figure
plot(sorted_act_distance)
hold on
plot(sorted_pred_distance,'o')
xlabel('Test Data Number')
ylabel('Distance')
%ylim([3 50])
title('MFP Result (SNR = INF)')
grid on
set(gca,'fontsize',30)

% acc = 100*sum(((pred_dist_class-act_distance_class) == 0))/length(act_distance_class);

mae = mean(abs((sorted_act_distance-sorted_pred_distance)));

diff = abs(sorted_act_distance-sorted_pred_distance);
percentwithin1km = 100*length(diff(diff<=1))/length(diff);
percentwithinp5km = 100*length(diff(diff<=.5))/length(diff);
percentwithinp1km = 100*length(diff(diff<=.1))/length(diff);
% disp(['acc = ' num2str(acc)])
disp(['mae = ' num2str(mae)])
disp(['percent within 1km = ' num2str(percentwithin1km)])
disp(['percent within 0.5km = ' num2str(percentwithinp5km)])
disp(['percent within 0.1km = ' num2str(percentwithinp1km)])
    
sorted_pred_distance =sorted_pred_distance;
sorted_act_distance = sorted_act_distance;
% plot
sorted_results = abs(mfp_avg(:,I));

for i = 1:size(sorted_results,2)
    sorted_results(:,i) = sorted_results(:,i)./sum(sorted_results(:,i));
end

figure
h = pcolor(sorted_act_distance,dist,100*(sorted_results));
set(h, 'EdgeColor', 'none');
xlabel('Actual Source Distance (km)')
ylabel('Predicted Source Distance (km)')
xlim([3 50])
ylim([3 50])
%caxis([0.025 0.05])
title('Bartlett MFP Result (SNR = INF)') 

hold on
plot(sorted_act_distance,sorted_act_distance,'-.k','LineWidth',3)
plot(sorted_act_distance,sorted_pred_distance,'ro','MarkerSize',4)
set(gca,'fontsize',25)
set(gca, 'YDir','normal')

%% Write predictions to files

dlmwrite('/Users/Rui/Documents/Graduate/Research/Range_Est_ML/model/mfp_test2_pred.csv',sorted_pred_distance,'precision',8)
dlmwrite('/Users/Rui/Documents/Graduate/Research/Range_Est_ML/model/mfp_test2_act.csv',sorted_act_distance,'precision',8)