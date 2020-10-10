
%% classfication

%data_mat(:,:,1:500) = oasn_cov(:,:,2551:end);
%data_mat(:,:,501:3050) = oasn_cov(:,:,1:2550);

data_mat = oasn_cov;

% labels_part = 3:0.5:50;
features = zeros(size(data_mat,3),size(data_mat,2)*(size(data_mat,2)+1));

for k = 1:size(data_mat,3)
    temp = [];
    for i = 1:size(data_mat,1)
        for j = i:size(data_mat,2)
            re = real(data_mat(i,j,k));
            im = imag(data_mat(i,j,k));
            
            temp = [temp re im];
            
            
        end
    end
    
    features(k,:) = temp;
end

% labels = [];
% for l = 1:length(labels_part)
%     labels = [labels labels_part(l)*ones(1,1)];
% end
% labels = labels.';

%%
dlmwrite('vec_mat_features_icex_src_test.csv',features,'precision',6)
csvwrite('vec_mat_clabels_icex_src_test.csv',labels_c)


%% USE THIS

features = zeros(size(oasn_cov_norm,3),size(oasn_cov_norm,2)*(size(oasn_cov_norm,2)+1));

for k = 1:size(oasn_cov_norm,3)
    temp = [];
    for i = 1:size(oasn_cov_norm,1)
        for j = i:size(oasn_cov_norm,2)
            re = real(oasn_cov_norm(i,j,k));
            im = imag(oasn_cov_norm(i,j,k));
            
            temp = [temp re im];
            
            
        end
    end
    
    features(k,:) = temp;
end

%%
dlmwrite('vec_mat_features_icex_src_testh_0.01int_norm.csv',features,'precision',6)
%dlmwrite('vec_mat_rlabels_icex_src_0.01trainbb.csv',labels,'precision',8)
%csvwrite('vec_mat_clabels_icex_src_0.01trainbb.csv',labels_c)
%dlmwrite('vec_mat_features_swellex_109hz2_test9.csv',features,'precision',6)
dlmwrite('vec_mat_rlabels_icex_src_testh_0.01int.csv',labels,'precision',8)
csvwrite('vec_mat_clabels_icex_src_testh_0.01int.csv',labels_c)



%% USE THIS For principle eigenvector features

features = zeros(size(oasn_cov,3),2*size(oasn_cov,1));

for k = 1:size(oasn_cov,3)
    temp = [];
    [V,D] = eig(oasn_cov(:,:,k));
    [d,ind] = sort(diag(D));
    Ds = D(ind,ind);
    Vs = V(:,ind);
    evector = Vs(:,end);
    for i = 1:length(evector)
        re = real(evector(i));
        im = imag(evector(i));
            
        temp = [temp re im];
            
    end
    
    features(k,:) = temp;
end

%%
dlmwrite('vec_mat_features_icex_src_0.01train_evec.csv',features,'precision',6)

%% USE THIS for pca

[coeff,score,latent,~,explained,~] = pca(features);
features_pca = features*coeff;

features_50p = features_pca(:,1:12);
features_99_9p = features_pca(:,1:187);

dlmwrite('vec_mat_features_icex_src_test2_pca50p.csv',features_50p,'precision',6)
dlmwrite('vec_mat_features_icex_src_test2_pca999p.csv',features_99_9p,'precision',6)
