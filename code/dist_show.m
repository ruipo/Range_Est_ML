%%read in mfp repmat
label_mfp = 3:0.01:50;
%label_mfp = 0:0.01:10;
rep_mat = rep_mat(:,:,2);
rep_mat = rep_mat./vecnorm(rep_mat);
dist_mat = zeros(size(rep_mat,2));

for i = 1:size(rep_mat,2)
    for j = i:size(rep_mat,2)
        
        diff = rep_mat(:,i) - rep_mat(:,j);
        dist_mat(i,j) = sqrt(diff'*diff);
        dist_mat(j,i) = dist_mat(i,j);
    end
end
%%
% figure
% imagesc(label_mfp,label_mfp,dist_mat./(max(max(dist_mat))));
% set(gca,'YDir', 'normal');

figure
subplot(2,1,1)
h = pcolor(label_mfp,label_mfp,dist_mat./(max(max(dist_mat))));
hold on
plot([3 50],[10 10],'-.k','linewidth',2)
set(h,'EdgeColor', 'none');
xlabel('Distance (km)')
ylabel('Distance (km)')
set(gca,'fontsize',20);
caxis([0.5 1])
title('MFP - Normalized Distance between Replica Vectors')
colormap jet

subplot(2,1,2)
plot(label_mfp,dist_mat(701,:)./(max(max(dist_mat(701,:)))),'b')
xlabel('Distance (km)')
ylabel('Normalized Vector Distance')
set(gca,'fontsize',20);
xlim([3 50])
title('Horizontal slice at 10 km')
grid on


%% read in mfp test rep

prefix = '/Users/Rui/Documents/Graduate/Research/Range_Est_ML/mfp/rpo_files/';
filename1 = [prefix 'testc.txt'];

    
fileID = fopen(filename1);
C = textscan(fileID,'%s%s%s%s%s%s%s%s%s','HeaderLines',35);

temp = zeros(length(C{1,7})-7,1);
for j = 1:length(C{1,7})-7
    temp(j,1) =  str2double(C{1,7}{j,1}) + 1i*str2double(C{1,8}{j,1}(1:end-1));
end

temp = temp(~isnan(temp));

rep = reshape(temp,[32,1001,3]); %array element X range X depth
rep = mean(rep(:,2,:),3);
rep = rep./norm(rep);
dist_mat_rep = zeros(1,size(rep_mat,2));

for j = 1:size(rep_mat,2)
        
    diff = rep - rep_mat(:,j);
    dist_mat_rep(j) = sqrt(diff'*diff);
end

%%

figure
plot(label_mfp,dist_mat_rep./max(dist_mat_rep))
xlim([3 50])
set(gca,'fontsize',25)
xlabel('Distance (km)')
ylabel('Normalized Vector Distance')
title('MFP (30.202 km, 0.1% Increase to BL Strength)')
grid on

%% read in cnnc ml training layer d output

layerd_output_train = dlmread('/Users/Rui/Documents/Graduate/Research/Range_Est_ML/output_files/layerd_output_train.tsv','\t');
layerd_output_train = layerd_output_train.';
labels_ml = dlmread('/Users/Rui/Documents/Graduate/Research/Range_Est_ML/output_files/training_input_labels.tsv');
[~,arg] = sort(labels_ml);
layerd_output_train = layerd_output_train(:,arg);

%%

dist_mat_ml = zeros(size(layerd_output_train,2));

for i = 1:size(layerd_output_train,2)
    for j = i:size(layerd_output_train,2)
        
        diff = layerd_output_train(:,i) - layerd_output_train(:,j);
        dist_mat_ml(i,j) = sqrt(diff'*diff);
        dist_mat_ml(j,i) = dist_mat_ml(i,j);
    end
end

n = 50;
dist_mat_ml_mean = reshape(dist_mat_ml(1:end-1,1:end-1),n,94,n,94);
dist_mat_ml_mean = squeeze(mean(dist_mat_ml_mean,1));
dist_mat_ml_mean = squeeze(mean(dist_mat_ml_mean,2));
%dist_mat_test2_mean = [dist_mat_test2_mean dist_mat_test2(:,end)];

label_c = 3:0.5:49.5;

%%
figure
imagesc(label_c,label_c,dist_mat_ml_mean./max(max(dist_mat_ml_mean)));
set(gca,'YDir', 'normal');
%set(p,'EdgeColor', 'none');

figure
subplot(2,1,1)
h = pcolor(label_c,label_c,dist_mat_ml_mean./(max(max(dist_mat_ml_mean))));
set(h,'EdgeColor', 'none');
hold on
plot([3 50],[10 10],'-.k','linewidth',2)
xlabel('Distance (km)')
ylabel('Distance (km)')
caxis([0.5 1])
set(gca,'fontsize',20);
title('CNN-C - Normalized Distance between FC Layer Output Vectors')
colorbar
colormap jet

subplot(2,1,2)
plot(label_c,dist_mat_ml_mean(15,:)./(max(max(dist_mat_ml_mean(15,:)))),'b','linewidth',2)
xlabel('Distance (km)')
ylabel('Normalized Vector Distance')
set(gca,'fontsize',20);
title('Horizontal slice at 10 km')
grid on

%% read in cnnc ml test2 layer d output
layerd_output_test2 = dlmread('~/Desktop/output_files/layerd_output_test2.tsv','\t');
layerd_output_test2 = layerd_output_test2.';
labels_test2 = dlmread('~/Desktop/output_files/layerd_output_test2_labels.tsv');
[~,arg] = sort(labels_test2(:,1));
labels_test2 = labels_test2(arg,:);
layerd_output_test2 = layerd_output_test2(:,arg);

%%

dist_mat_test2 = zeros(size(layerd_output_test2,2),size(layerd_output_train,2));

for i = 1:size(layerd_output_test2,2)
    for j = 1:size(layerd_output_train,2)
        
        diff = layerd_output_test2(:,i) - layerd_output_train(:,j);
        dist_mat_test2(i,j) = sqrt(diff'*diff);
    end
end

n = 50;
dist_mat_test2_mean = reshape(dist_mat_test2(:,1:end-1),1000,n,[]);
dist_mat_test2_mean = squeeze(mean(dist_mat_test2_mean,2));
dist_mat_test2_mean = [dist_mat_test2_mean dist_mat_test2(:,end)];

label_c = 3:0.5:50;

%%
figure
plot(label_c,dist_mat_test2_mean(153,:)./max(max(dist_mat_test2_mean(153,:))))

[~,argmin] = sort(dist_mat_test2_mean(153,:)./max(max(dist_mat_test2_mean(153,:))));
nn = label_c(argmin).';

%% read in cnnr ml training layer d output
layerd_output_train = dlmread('/Users/Rui/Documents/Graduate/Research/Range_Est_ML/output_files/layerd_output_train_r.tsv','\t');
layerd_output_train = layerd_output_train.';
labels_ml = dlmread('/Users/Rui/Documents/Graduate/Research/Range_Est_ML/output_files/layerd_output_train_rlabels.tsv');
[~,arg] = sort(labels_ml);
layerd_output_train = layerd_output_train(:,arg);

%%

dist_mat_ml = zeros(size(layerd_output_train,2));

for i = 1:size(layerd_output_train,2)
    i
    for j = i:size(layerd_output_train,2)
        
        diff = layerd_output_train(:,i) - layerd_output_train(:,j);
        dist_mat_ml(i,j) = sqrt(diff'*diff);
        dist_mat_ml(j,i) = dist_mat_ml(i,j);
    end
end

dist_mat_ml = dist_mat_ml(1:4701,1:4701);
%%
% figure
% imagesc(label_mfp,label_mfp,dist_mat_ml./max(max(dist_mat_ml)));
% set(gca,'YDir', 'normal');
% %set(p,'EdgeColor', 'none');

figure
subplot(2,1,1)
h = pcolor(label_mfp,label_mfp,dist_mat_ml./(max(max(dist_mat_ml))));
set(h,'EdgeColor', 'none');
hold on
plot([3 50],[10 10],'-.k','linewidth',2)
xlabel('Distance (km)')
ylabel('Distance (km)')
caxis([0.1 1])
set(gca,'fontsize',20);
title('CNN-r - Normalized Distance between FC Layer Output Vectors')
colorbar
colormap jet

subplot(2,1,2)
plot(label_mfp,dist_mat_ml(701,:)./(max(max(dist_mat_ml(701,:)))),'b')
xlabel('Distance (km)')
ylabel('Normalized Vector Distance')
set(gca,'fontsize',20);
title('Horizontal slice at 10 km')
xlim([3 50])
grid on

%% REad in cnnr ml test layer d output
layerd_output_test2 = dlmread('~/Desktop/layerd_output_32km_testc_r.tsv','\t');
layerd_output_test2 = layerd_output_test2.';
dist_mat_test2 = zeros(size(layerd_output_test2,2),size(layerd_output_train,2));

for i = 1:size(layerd_output_test2,2)
    for j = 1:size(layerd_output_train,2)
        
        diff = layerd_output_test2(:,i) - layerd_output_train(:,j);
        dist_mat_test2(i,j) = sqrt(diff'*diff);
    end
end
%%
figure
plot(label_mfp,dist_mat_test2./(max(max(dist_mat_test2))))
xlabel('Distance (km)')
ylabel('Normalized Vector Distance')
set(gca,'fontsize',25);
title('CNN-R - Normalized Distance between FC Layer Output Vectors (10 km)')
xlim([3 50])
grid on